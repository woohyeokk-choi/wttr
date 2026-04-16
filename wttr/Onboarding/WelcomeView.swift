import SwiftUI
import SharedKit

struct WelcomeView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Text("wttr")
                .font(.system(size: 48, weight: .bold, design: .rounded))
            Text("Not the weather.\nJust what to do about it.")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Spacer()
            Button(action: onContinue) {
                Text("Get Started")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .padding(.top, 56)
    }
}
