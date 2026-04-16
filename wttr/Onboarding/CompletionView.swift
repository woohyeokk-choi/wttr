import SwiftUI
import SharedKit

struct CompletionView: View {
    @Environment(SubscriptionStore.self) private var subscriptionStore
    let onDone: () -> Void

    @State private var showPaywall = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)
            Text("You're all set!")
                .font(.system(size: 28, weight: .bold))
            Text("wttr will help you make weather decisions every day.")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
            Button {
                let isProUser = subscriptionStore.isProUser
                if !isProUser {
                    showPaywall = true
                } else {
                    onDone()
                }
            } label: {
                Text("Start Using wttr")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .padding(.top, 56)
        .sheet(isPresented: $showPaywall, onDismiss: onDone) {
            SubscriptionView(triggerFeature: nil)
        }
    }
}
