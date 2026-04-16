import Foundation

extension DecisionEngine {
    func evaluateUmbrella(hourlyForecast: [HourlyForecast]) -> UmbrellaDecision {
        let forecast = Array(hourlyForecast.prefix(Thresholds.lookAheadHours))

        guard !forecast.isEmpty else {
            return UmbrellaDecision(
                severity: .safe,
                headline: "No forecast data",
                description: "Hourly forecast is unavailable.",
                rainStartTime: nil,
                rainEndTime: nil,
                maxPrecipChance: 0,
                precipitationType: .none
            )
        }

        let maxPrecipChance = forecast.map(\.precipitationChance).max() ?? 0

        if maxPrecipChance < Thresholds.noRainThreshold {
            return UmbrellaDecision(
                severity: .safe,
                headline: "No rain expected",
                description: "Precipitation chance stays below \(Int(Thresholds.noRainThreshold * 100))%.",
                rainStartTime: nil,
                rainEndTime: nil,
                maxPrecipChance: maxPrecipChance,
                precipitationType: .none
            )
        }

        // Find rain start: first entry where precipChance >= rainLikelyThreshold
        guard let rainStartIndex = forecast.firstIndex(where: { $0.precipitationChance >= Thresholds.rainLikelyThreshold }) else {
            // maxPrecip >= noRainThreshold but no entry hits rainLikelyThreshold
            return UmbrellaDecision(
                severity: .caution,
                headline: "Slight chance of rain",
                description: "Up to \(Int(maxPrecipChance * 100))% chance of precipitation.",
                rainStartTime: nil,
                rainEndTime: nil,
                maxPrecipChance: maxPrecipChance,
                precipitationType: dominantPrecipType(in: forecast, from: nil, to: nil)
            )
        }

        let rainStartTime = forecast[rainStartIndex].hour

        // Find rain end: last consecutive entry from rainStartIndex where precipChance >= rainLikelyThreshold
        var rainEndIndex = rainStartIndex
        for i in (rainStartIndex + 1)..<forecast.count {
            if forecast[i].precipitationChance >= Thresholds.rainLikelyThreshold {
                rainEndIndex = i
            } else {
                break
            }
        }
        // Rain end time is the end of the last consecutive rain hour (+ 1 hour)
        let rainEndTime = forecast[rainEndIndex].hour.addingTimeInterval(3600)

        let precipType = dominantPrecipType(in: forecast, from: rainStartIndex, to: rainEndIndex)

        // Determine how soon rain starts
        let now = forecast[0].hour
        let hoursUntilRain = rainStartTime.timeIntervalSince(now) / 3600.0

        if hoursUntilRain < 2 {
            return UmbrellaDecision(
                severity: .danger,
                headline: "Rain soon — grab an umbrella",
                description: "Precipitation expected within the next 2 hours.",
                rainStartTime: rainStartTime,
                rainEndTime: rainEndTime,
                maxPrecipChance: maxPrecipChance,
                precipitationType: precipType
            )
        }

        // Rain later today
        let timeString = rainStartTime.shortTimeString(in: .current)
        return UmbrellaDecision(
            severity: .warning,
            headline: "Rain from \(timeString) — grab an umbrella",
            description: "Precipitation expected starting around \(timeString).",
            rainStartTime: rainStartTime,
            rainEndTime: rainEndTime,
            maxPrecipChance: maxPrecipChance,
            precipitationType: precipType
        )
    }

    /// Returns the precipitation type of the entry with the highest precipChance within the rain window.
    private func dominantPrecipType(in forecast: [HourlyForecast], from startIndex: Int?, to endIndex: Int?) -> PrecipitationType {
        let slice: ArraySlice<HourlyForecast>
        if let start = startIndex, let end = endIndex {
            slice = forecast[start...end]
        } else {
            slice = forecast[forecast.startIndex..<forecast.endIndex]
        }

        guard let dominant = slice.max(by: { $0.precipitationChance < $1.precipitationChance }) else {
            return .none
        }
        return dominant.precipitationType
    }
}
