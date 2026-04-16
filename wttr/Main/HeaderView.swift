import SwiftUI
import SharedKit

struct HeaderView: View {
    let location: LocationData
    @Environment(WeatherStore.self) private var weatherStore
    @Environment(PreferencesStore.self) private var preferencesStore
    @Environment(LocationStore.self) private var locationStore

    var body: some View {
        HStack(spacing: 8) {
            Button {
                let weatherStore = weatherStore
                let preferencesStore = preferencesStore
                let location = location
                Task { await weatherStore.fetchWeather(for: location, enabledDecisions: preferencesStore.enabledDecisions) }
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .accessibilityLabel("Refresh weather for \(location.city)")

            Spacer(minLength: 4)

            HStack(spacing: 6) {
                Text(location.city)
                    .font(.system(size: 17, weight: .medium))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                if locationStore.isLocationBlocked {
                    LocationBlockedBadge(size: .compact, showsLabel: false)
                }
            }

            Spacer(minLength: 4)

            ShareLink(item: "Weather in \(location.city): \(weatherStore.currentWeather?.temperature.formattedTemperature(unit: preferencesStore.temperatureUnit) ?? "—")") {
                Image(systemName: "square.and.arrow.up")
            }
            .accessibilityLabel("Share weather for \(location.city)")
        }
        .padding(.horizontal, 16)
    }
}
