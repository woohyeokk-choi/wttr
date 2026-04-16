import SwiftUI
import SharedKit

/// Widget Intro — first of the widget onboarding sub-flow (Duolingo pattern).
/// Shows a preview + two CTAs: primary "See How to Install" and secondary "No Thanks".
struct WidgetSetupView: View {
    let onSeeHowToInstall: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Check your decisions\nwithout opening the app.")
                .font(.system(size: 24, weight: .bold))
                .multilineTextAlignment(.center)

            // Preview: small widget mock
            WidgetPreviewMock()
                .padding(.vertical, 12)

            Text("Pin wttr to your Home Screen and see at a glance if you need an umbrella, SPF, or a warmer jacket.")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            VStack(spacing: 12) {
                Button(action: onSeeHowToInstall) {
                    Text("See How to Install")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                Button(action: onSkip) {
                    Text("No Thanks")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .padding(.top, 56)
    }
}

private struct WidgetPreviewMock: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "umbrella.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color("Warning"))
                Text("Rain at 3 PM")
                    .font(.system(size: 15, weight: .bold))
            }
            Text("Bring an umbrella")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            HStack(spacing: 10) {
                Image(systemName: "thermometer.low")
                    .foregroundStyle(Color("Info"))
                Image(systemName: "sun.max.trianglebadge.exclamationmark")
                    .foregroundStyle(Color("Warning"))
                Image(systemName: "aqi.low")
                    .foregroundStyle(Color("Safe"))
            }
            .font(.system(size: 14))
        }
        .padding(14)
        .frame(width: 155, height: 155, alignment: .topLeading)
        .background(Color("Surface"))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
    }
}
