import SwiftUI

struct WttrProUpgradeOverlay: View {
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)

            VStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                Text("Upgrade to Pro")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text("Unlock medium & large widgets with more detail")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(16)
        }
    }
}
