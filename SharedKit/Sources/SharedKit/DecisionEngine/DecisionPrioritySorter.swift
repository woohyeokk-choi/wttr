import Foundation

extension DecisionEngine {
    func sortByPriority(
        _ decisions: [any Decision],
        weather: WeatherCondition,
        hourlyForecast: [HourlyForecast],
        airQuality: AirQualityData?
    ) -> [any Decision] {
        // Separate temperature (always first) from the rest
        var temperatureDecision: (any Decision)?
        var others: [any Decision] = []

        for decision in decisions {
            if decision.type == .temperature {
                temperatureDecision = decision
            } else {
                others.append(decision)
            }
        }

        // Score each non-temperature decision
        let scored = others.map { decision -> (decision: any Decision, score: Double, tiebreaker: Int) in
            let score = priorityScore(for: decision, weather: weather, hourlyForecast: hourlyForecast, airQuality: airQuality)
            let tiebreaker = tiebreakerOrder(for: decision.type)
            return (decision, score, tiebreaker)
        }

        // Stable sort: by score descending, then by tiebreaker ascending on tie
        let sorted = scored.sorted { lhs, rhs in
            if lhs.score != rhs.score {
                return lhs.score > rhs.score
            }
            return lhs.tiebreaker < rhs.tiebreaker
        }

        var result: [any Decision] = []
        if let temp = temperatureDecision {
            result.append(temp)
        }
        result.append(contentsOf: sorted.map(\.decision))
        return result
    }

    private func priorityScore(
        for decision: any Decision,
        weather: WeatherCondition,
        hourlyForecast: [HourlyForecast],
        airQuality: AirQualityData?
    ) -> Double {
        switch decision.type {
        case .temperature:
            return 0 // N/A — temperature is always first
        case .umbrella:
            let maxPrecip = hourlyForecast.prefix(12).map(\.precipitationChance).max() ?? 0
            return min(max(maxPrecip, 0), 1)
        case .sunscreen:
            return min(Double(weather.uvIndex) / 11.0, 1.0)
        case .sunglasses:
            let highUV = weather.uvIndex >= Thresholds.uvThreshold
            let clearSky = weather.cloudCover < Thresholds.cloudThreshold
            return (highUV && clearSky) ? 0.8 : 0.2
        case .airQuality:
            let aqi = airQuality?.aqi ?? 0
            return min(Double(aqi) / 200.0, 1.0)
        }
    }

    /// Lower value = higher priority on tie
    private func tiebreakerOrder(for type: DecisionType) -> Int {
        switch type {
        case .temperature: return 0
        case .umbrella:    return 1
        case .sunscreen:   return 2
        case .sunglasses:  return 3
        case .airQuality:  return 4
        }
    }
}
