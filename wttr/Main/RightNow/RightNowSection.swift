import SwiftUI
import SharedKit

struct RightNowSection: View {
    @Environment(WeatherStore.self) private var weatherStore
    @Environment(PreferencesStore.self) private var preferencesStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Right now")
                .font(.system(size: 28, weight: .bold))
                .padding(.horizontal, 16)

            if let condition = weatherStore.currentWeather {
                CurrentConditionView(condition: condition, yesterday: weatherStore.yesterdayComparison, temperatureUnit: preferencesStore.temperatureUnit)
            }

            if !weatherStore.decisions.isEmpty {
                DecisionCardGrid(decisions: weatherStore.decisions)
                    .padding(.horizontal, 16)
            }
        }
    }
}
