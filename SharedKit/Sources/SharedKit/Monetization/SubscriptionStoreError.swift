import Foundation

public enum SubscriptionStoreError: Error, Sendable {
    case productsNotLoaded
    case purchaseFailed(description: String)
    case purchasePending
    case userCancelled
    case verificationFailed
    case storeKitUnavailable
    case unknown(description: String)
}
