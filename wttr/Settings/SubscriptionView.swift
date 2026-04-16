import SwiftUI
import StoreKit
import SharedKit

/// Paywall for wttr Pro — **one-time purchase**, not a subscription.
struct SubscriptionView: View {
    @Environment(SubscriptionStore.self) private var subscriptionStore
    @Environment(\.dismiss) private var dismiss

    let triggerFeature: Feature?

    @State private var purchaseError: String?
    @State private var showError = false

    private let proFeatures: [(String, String, String)] = [
        ("rectangle.3.group.fill", "All Widgets", "Small, medium, large, and Lock Screen"),
        ("bell.badge.fill", "Event Alerts", "Morning briefings & rain alerts"),
        ("map.fill", "Multiple Locations", "Track weather for every place you care about"),
        ("paintpalette.fill", "Themes", "Match the app to your style")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    headerSection
                    featuresSection
                    purchaseSection
                }
                .padding(24)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 22))
                    }
                }
            }
        }
        .task {
            if subscriptionStore.availableProducts.isEmpty {
                await subscriptionStore.loadProducts()
            }
        }
        .alert("Purchase Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(purchaseError ?? "Something went wrong. Please try again.")
        }
    }

    @ViewBuilder
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 60))
                .foregroundStyle(.tint)

            Text("wttr Pro")
                .font(.system(size: 32, weight: .bold))

            Text("One-time purchase. Yours forever.")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    private var featuresSection: some View {
        VStack(spacing: 12) {
            ForEach(proFeatures, id: \.0) { icon, title, subtitle in
                HStack(alignment: .top, spacing: 16) {
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundStyle(.tint)
                        .frame(width: 32)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 16, weight: .semibold))
                        Text(subtitle)
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "checkmark")
                        .foregroundStyle(.tint)
                        .font(.system(size: 14, weight: .semibold))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color("Surface"))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    @ViewBuilder
    private var purchaseSection: some View {
        VStack(spacing: 12) {
            if subscriptionStore.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
            } else if subscriptionStore.isProUser {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.tint)
                    Text("You own wttr Pro")
                        .font(.system(size: 17, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color("Surface"))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                Button {
                    purchasePro()
                } label: {
                    Group {
                        if let product = subscriptionStore.availableProducts.first {
                            Text("Get wttr Pro — \(product.displayPrice)")
                        } else {
                            Text("Get wttr Pro")
                        }
                    }
                    .font(.system(size: 18, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .disabled(subscriptionStore.isLoading || subscriptionStore.availableProducts.isEmpty)

                Button {
                    restorePurchases()
                } label: {
                    Text("Restore Purchases")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                }
            }

            if let error = subscriptionStore.lastError {
                Text(error.localizedDescription)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Text("One-time purchase • Family Sharing supported\nRestore on any device with your Apple ID.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
    }

    private func purchasePro() {
        guard let product = subscriptionStore.availableProducts.first else { return }
        let store = subscriptionStore
        Task { @MainActor in
            do {
                try await store.purchase(product)
                if store.isProUser { dismiss() }
            } catch SubscriptionStoreError.userCancelled {
                // No-op: user dismissed the sheet
            } catch SubscriptionStoreError.purchasePending {
                purchaseError = "Your purchase is pending approval. You'll get access once it's complete."
                showError = true
            } catch {
                purchaseError = error.localizedDescription
                showError = true
            }
        }
    }

    private func restorePurchases() {
        let store = subscriptionStore
        Task { @MainActor in
            await store.restorePurchases()
            if store.isProUser {
                dismiss()
            }
        }
    }
}
