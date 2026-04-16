import WidgetKit
import SharedKit

struct WidgetDecision: Codable, Sendable {
    let type: DecisionType
    let severity: DecisionSeverity
    let icon: String
    let shortLabel: String
    let headline: String
    let description: String
    let isNeeded: Bool
}

struct WidgetHourlyItem: Codable, Sendable {
    let hour: Date
    let temp: Double
    let condition: WeatherConditionType
}

struct WidgetDailyItem: Codable, Sendable {
    let day: Date
    let condition: WeatherConditionType
    let low: Double
    let high: Double
    let precipChance: Double
}

struct WeatherWidgetEntry: TimelineEntry {
    let date: Date
    let location: String
    let temperature: String
    let feelsLike: String
    let vsYesterday: String
    let vsYesterdayDirection: TemperatureDirection
    let condition: WeatherConditionType
    let decisions: [WidgetDecision]
    let hourlySnippet: [WidgetHourlyItem]
    let weeklySnippet: [WidgetDailyItem]
    let isStale: Bool
    let lastFetchTime: Date?
    let isProUser: Bool
    let isLocationBlocked: Bool

    static var placeholder: WeatherWidgetEntry {
        WeatherWidgetEntry(
            date: Date(), location: "San Francisco",
            temperature: "63°", feelsLike: "Feels 51°",
            vsYesterday: "7° colder", vsYesterdayDirection: .colder,
            condition: .partlyCloudy,
            decisions: [
                WidgetDecision(type: .umbrella, severity: .warning, icon: "umbrella.fill", shortLabel: "Rain 3PM", headline: "Bring an umbrella", description: "Rain likely starting 3 PM", isNeeded: true),
                WidgetDecision(type: .sunscreen, severity: .warning, icon: "sun.max.trianglebadge.exclamationmark", shortLabel: "UV 8", headline: "Wear SPF 50+", description: "UV 8 · very high", isNeeded: true),
                WidgetDecision(type: .temperature, severity: .caution, icon: "thermometer.low", shortLabel: "7° colder", headline: "Dress warmer", description: "7° colder than yesterday", isNeeded: true),
                WidgetDecision(type: .airQuality, severity: .safe, icon: "aqi.low", shortLabel: "Good air", headline: "Air quality good", description: "AQI 42 · healthy", isNeeded: false)
            ],
            hourlySnippet: (0..<8).map { i in
                WidgetHourlyItem(hour: Date().addingTimeInterval(Double(i) * 3600), temp: 17.0 - Double(i) * 0.8, condition: .partlyCloudy)
            },
            weeklySnippet: (0..<6).map { i in
                WidgetDailyItem(day: Date().addingTimeInterval(Double(i + 1) * 86400), condition: .partlyCloudy, low: 10 + Double(i), high: 20 + Double(i), precipChance: i == 1 ? 0.4 : 0.1)
            },
            isStale: false, lastFetchTime: Date(), isProUser: false, isLocationBlocked: false
        )
    }
}
