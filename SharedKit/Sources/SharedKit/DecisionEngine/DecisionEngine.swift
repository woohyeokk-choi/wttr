import Foundation

public struct DecisionEngine: Sendable {
    public init() {}

    /// Thresholds namespace
    public enum Thresholds {
        // Temperature
        public static let similarThreshold: Double = 2.0  // degrees Celsius

        // Umbrella
        public static let noRainThreshold: Double = 0.20      // 20%
        public static let rainLikelyThreshold: Double = 0.40  // 40%
        public static let lookAheadHours: Int = 24

        // Sunscreen (UV index breakpoints)
        public static let uvLow: ClosedRange<Int> = 0...2
        public static let uvModerate: ClosedRange<Int> = 3...5
        public static let uvHigh: ClosedRange<Int> = 6...7
        public static let uvVeryHigh: Int = 8

        // Sunglasses
        public static let uvThreshold: Int = 4
        public static let cloudThreshold: Double = 0.50

        // Air Quality (AQI breakpoints)
        public static let aqiGoodMax: Int = 50
        public static let aqiModerateMax: Int = 100
        public static let aqiUnhealthySensitiveMax: Int = 150
        public static let aqiUnhealthyMax: Int = 200
        public static let aqiVeryUnhealthyMin: Int = 201
    }

    /// Main evaluation entry point
    public func evaluate(
        weather: WeatherCondition,
        yesterday: YesterdayComparison?,
        airQuality: AirQualityData?,
        hourlyForecast: [HourlyForecast],
        enabledDecisions: Set<DecisionType>
    ) -> [any Decision] {
        var decisions: [any Decision] = []

        // Temperature is ALWAYS evaluated
        decisions.append(evaluateTemperature(weather: weather, yesterday: yesterday))

        // Evaluate other enabled types
        let enabledSet = enabledDecisions.union([.temperature])
        if enabledSet.contains(.umbrella) {
            decisions.append(evaluateUmbrella(hourlyForecast: hourlyForecast))
        }
        if enabledSet.contains(.sunscreen) {
            decisions.append(evaluateSunscreen(weather: weather))
        }
        if enabledSet.contains(.sunglasses) {
            decisions.append(evaluateSunglasses(weather: weather))
        }
        if enabledSet.contains(.airQuality), let aq = airQuality {
            decisions.append(evaluateAirQuality(airQuality: aq))
        }

        // Sort: temperature always first, rest by priority score
        return sortByPriority(decisions, weather: weather, hourlyForecast: hourlyForecast, airQuality: airQuality)
    }
}
