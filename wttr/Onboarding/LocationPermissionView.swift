import SwiftUI
import SharedKit

struct LocationPermissionView: View {
    @Environment(LocationStore.self) private var locationStore
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "location.fill")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
            Text("Where are you?")
                .font(.system(size: 28, weight: .bold))
            Text("wttr needs your location to show local weather and decisions.")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
            VStack(spacing: 12) {
                Button {
                    let store = locationStore
                    Task {
                        await store.requestPermission()
                        onContinue()
                    }
                } label: {
                    Text("Allow Location")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                Button {
                    onContinue()
                } label: {
                    Text("Enter City Manually")
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
