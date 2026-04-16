import SwiftUI
import StoreKit

typealias SKTransaction = StoreKit.Transaction

enum SubscriptionStoreError: Error {
    case productsNotLoaded
    case verificationFailed
    case userCancelled
    case purchasePending
    case purchaseFailed(description: String)
    case unknown(description: String)
}

/// Store for wttr Pro — a **one-time, non-consumable** lifetime unlock.
///
/// Despite the historical name, this type owns the lifetime entitlement, not a
/// subscription. Renaming is deferred because 65+ call sites reference
/// `SubscriptionStore` by name.
@Observable
final class SubscriptionStore: @unchecked Sendable {
    private(set) var isProUser: Bool = false
    private(set) var availableProducts: [Product] = []
    private(set) var isLoading: Bool = false
    private(set) var lastError: (any Error)?
    private var transactionListener: Task<Void, Never>?

    /// Non-consumable product ID. Must match App Store Connect exactly.
    static let lifetimeProductID = "com.wttr.pro.lifetime"

    init() {}

    func startTransactionListener() {
        transactionListener = Task.detached { [weak self] in
            for await result in SKTransaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self?.refreshEntitlement()
                }
            }
        }
    }

    func initialize() async {
        await loadProducts()
        await refreshEntitlement()
    }

    func loadProducts() async {
        do {
            availableProducts = try await Product.products(for: [Self.lifetimeProductID])
            if availableProducts.isEmpty {
                lastError = SubscriptionStoreError.productsNotLoaded
            } else {
                lastError = nil
            }
        } catch {
            lastError = error
        }
    }

    @discardableResult
    func purchase(_ product: Product) async throws -> SKTransaction {
        isLoading = true
        defer { isLoading = false }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            guard case .verified(let transaction) = verification else {
                throw SubscriptionStoreError.verificationFailed
            }
            await transaction.finish()
            await refreshEntitlement()
            return transaction
        case .userCancelled:
            throw SubscriptionStoreError.userCancelled
        case .pending:
            // Ask-to-Buy / SCA pending: transaction listener will pick it up.
            throw SubscriptionStoreError.purchasePending
        @unknown default:
            throw SubscriptionStoreError.unknown(description: "Unknown purchase result")
        }
    }

    /// Restore non-consumable purchases. `AppStore.sync()` forces a re-fetch from
    /// App Store servers and will prompt Apple ID login if required.
    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }
        try? await AppStore.sync()
        await refreshEntitlement()
    }

    /// Scan `Transaction.currentEntitlements` for a verified, non-revoked lifetime
    /// transaction. Lifetime purchases have no `expirationDate`.
    func refreshEntitlement() async {
        var owned = false
        for await result in SKTransaction.currentEntitlements {
            guard case .verified(let transaction) = result,
                  transaction.productID == Self.lifetimeProductID,
                  transaction.revocationDate == nil
            else { continue }
            owned = true
        }
        isProUser = owned
        // Persist to App Group so the widget extension can read without StoreKit.
        UserDefaults(suiteName: "group.com.wttr.app")?.set(owned, forKey: "subscription.isProUser")
    }

    /// Back-compat alias for older callers that expected a subscription-style check.
    func checkEntitlement() async { await refreshEntitlement() }

    deinit {
        transactionListener?.cancel()
    }
}
