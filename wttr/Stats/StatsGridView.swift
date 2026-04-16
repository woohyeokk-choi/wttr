import SwiftUI
import SharedKit

struct StatsGridView: View {
    @Environment(WeatherStore.self) private var weatherStore

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(StatCategory.allCases, id: \.self) { category in
                    NavigationLink(value: category) {
                        StatsCardView(
                            category: category,
                            value: currentValue(for: category),
                            unit: unit(for: category)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
    }

    private func currentValue(for category: StatCategory) -> String {
        guard let weather = weatherStore.currentWeather else { return "--" }
        switch category {
        case .precipitation:
            if let hourly = weatherStore.hourlyForecast.first {
                return String(format: "%.0f%%", hourly.precipitationChance * 100)
            }
            return "--"
        case .wind:
            return String(format: "%.0f", weather.windSpeed)
        case .humidity:
            return String(format: "%.0f%%", weather.humidity * 100)
        case .uvIndex:
            return "\(weather.uvIndex)"
        case .cloudCover:
            return String(format: "%.0f%%", weather.cloudCover * 100)
        case .visibility:
            return "--"
        case .pressure:
            return "--"
        case .airQuality:
            return weatherStore.airQuality.map { "\($0.aqi)" } ?? "--"
        case .daylight:
            if let today = weatherStore.dailyForecast.first {
                let hours = today.sunset.timeIntervalSince(today.sunrise) / 3600
                return String(format: "%.1fh", hours)
            }
            return "--"
        }
    }

    private func unit(for category: StatCategory) -> String {
        switch category {
        case .precipitation: return "chance"
        case .wind: return "km/h"
        case .humidity: return ""
        case .uvIndex: return "index"
        case .cloudCover: return ""
        case .visibility: return "km"
        case .pressure: return "hPa"
        case .airQuality: return "AQI"
        case .daylight: return "today"
        }
    }
}
