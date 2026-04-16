import SwiftUI
import SharedKit

struct ThisWeekSection: View {
    @Environment(WeatherStore.self) private var weatherStore
    @Environment(PreferencesStore.self) private var preferencesStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This week")
                .font(.system(size: 28, weight: .bold))
                .padding(.horizontal, 16)

            if !weatherStore.dailyForecast.isEmpty {
                let allHighs = weatherStore.dailyForecast.map(\.high)
                let allLows = weatherStore.dailyForecast.map(\.low)
                let highText = Int(preferencesStore.temperatureUnit.convert(fromCelsius: allHighs.max() ?? 0).rounded())
                let lowText = Int(preferencesStore.temperatureUnit.convert(fromCelsius: allLows.min() ?? 0).rounded())
                Text("Highs reaching \(highText)°, low of \(lowText)°.")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
            }

            WeeklyForecastList(
                dailyForecast: weatherStore.dailyForecast,
                temperatureUnit: preferencesStore.temperatureUnit
            )
            .padding(.horizontal, 16)
        }
    }
}
