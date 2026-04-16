import SwiftUI
import SharedKit

struct LocationView: View {
    @Environment(LocationStore.self) private var locationStore
    @Environment(WeatherStore.self) private var weatherStore
    @Environment(PreferencesStore.self) private var preferencesStore

    var body: some View {
        if locationStore.savedLocations.isEmpty {
            if locationStore.isLocationBlocked {
                // iOS has explicitly denied/restricted us — the system dialog
                // cannot be re-presented, so direct the user to Settings.
                ContentUnavailableView {
                    Label("Location is off", systemImage: "location.slash.fill")
                        .foregroundStyle(.red)
                } description: {
                    Text("wttr can't show local weather or decisions without location access. Turn it on in Settings → wttr → Location.")
                } actions: {
                    LocationBlockedBadge(size: .prominent)
                }
            } else {
                ContentUnavailableView {
                    Label("No Location", systemImage: "location.slash")
                } description: {
                    Text("Allow location access to see weather")
                } actions: {
                    Button("Allow Location") {
                        let locationStore = locationStore
                        Task { await locationStore.requestPermission() }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        } else {
            TabView(selection: Binding(
                get: { locationStore.selectedLocationIndex },
                set: { locationStore.selectLocation(at: $0) }
            )) {
                ForEach(Array(locationStore.savedLocations.enumerated()), id: \.offset) { index, location in
                    WeatherPageView(location: location)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onAppear {
                if let location = locationStore.selectedLocation {
                    let weatherStore = weatherStore
                    let preferencesStore = preferencesStore
                    Task {
                        await weatherStore.fetchWeather(for: location, enabledDecisions: preferencesStore.enabledDecisions)
                    }
                }
            }
        }
    }
}
