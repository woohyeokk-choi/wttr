import Foundation

extension DecisionEngine {
    func evaluateTemperature(weather: WeatherCondition, yesterday: YesterdayComparison?) -> TemperatureDecision {
        guard let yesterday else {
            return TemperatureDecision(
                severity: .safe,
                headline: "Temperature data unavailable",
                description: "No comparison data from yesterday.",
                diff: 0,
                direction: .similar,
                todayHigh: weather.temperature,
                yesterdayHigh: 0
            )
        }

        let diff = weather.temperature - yesterday.high

        if diff == 0 {
            return TemperatureDecision(
                severity: .safe,
                headline: "Same as yesterday",
                description: "Today's high matches yesterday's.",
                diff: 0,
                direction: .similar,
                todayHigh: weather.temperature,
                yesterdayHigh: yesterday.high
            )
        }

        if abs(diff) <= Thresholds.similarThreshold {
            return TemperatureDecision(
                severity: .safe,
                headline: "About the same as yesterday",
                description: "Only \(Int(abs(diff).rounded()))° difference from yesterday.",
                diff: diff,
                direction: .similar,
                todayHigh: weather.temperature,
                yesterdayHigh: yesterday.high
            )
        }

        if diff > Thresholds.similarThreshold {
            return TemperatureDecision(
                severity: .caution,
                headline: "\(Int(diff.rounded()))° warmer — dress lighter",
                description: "Today is noticeably warmer than yesterday.",
                diff: diff,
                direction: .warmer,
                todayHigh: weather.temperature,
                yesterdayHigh: yesterday.high
            )
        }

        // diff < -similarThreshold
        return TemperatureDecision(
            severity: .warning,
            headline: "\(Int(abs(diff).rounded()))° colder — layer up",
            description: "Today is noticeably colder than yesterday.",
            diff: diff,
            direction: .colder,
            todayHigh: weather.temperature,
            yesterdayHigh: yesterday.high
        )
    }
}
