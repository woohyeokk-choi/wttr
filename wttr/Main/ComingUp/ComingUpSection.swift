import SwiftUI
import SharedKit

struct ComingUpSection: View {
    @Environment(WeatherStore.self) private var weatherStore
    @Environment(PreferencesStore.self) private var preferencesStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Coming up")
                .font(.system(size: 28, weight: .bold))
                .padding(.horizontal, 16)
            SummaryTextView(summary: generateSummary())
            if !weatherStore.hourlyForecast.isEmpty {
                HourlyBarChartView(hourlyForecast: weatherStore.hourlyForecast, temperatureUnit: preferencesStore.temperatureUnit)
            }
        }
    }

    private func generateSummary() -> String {
        guard let current = weatherStore.currentWeather else { return "" }
        let hasRain = weatherStore.hourlyForecast.contains { $0.precipitationChance >= 0.40 }
        if hasRain {
            if let rainHour = weatherStore.hourlyForecast.first(where: { $0.precipitationChance >= 0.40 }) {
                let timeStr = rainHour.hour.shortTimeString(in: TimeZone.current)
                return "\(current.condition.displayName). Rain after \(timeStr)."
            }
        }
        return "\(current.condition.displayName) for the next few hours."
    }
}
