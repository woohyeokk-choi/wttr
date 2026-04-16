import SwiftUI
import SharedKit

struct TodaySection: View {
    @Environment(WeatherStore.self) private var weatherStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today")
                .font(.system(size: 28, weight: .bold))
                .padding(.horizontal, 16)
            if !weatherStore.hourlyForecast.isEmpty {
                FourBlockGridView(hourlyForecast: weatherStore.hourlyForecast)
                    .padding(.horizontal, 16)
            }
        }
    }
}
