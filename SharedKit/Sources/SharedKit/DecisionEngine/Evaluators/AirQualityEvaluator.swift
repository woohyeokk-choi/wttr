extension DecisionEngine {
    func evaluateAirQuality(airQuality: AirQualityData) -> AirQualityDecision {
        let aqi = airQuality.aqi

        if aqi <= Thresholds.aqiGoodMax {
            return AirQualityDecision(
                severity: .safe,
                headline: "Air quality good — breathe easy",
                description: "AQI is \(aqi). No precautions needed.",
                aqi: aqi,
                category: airQuality.category
            )
        }

        if aqi <= Thresholds.aqiModerateMax {
            return AirQualityDecision(
                severity: .caution,
                headline: "Moderate air quality",
                description: "AQI is \(aqi). Sensitive individuals should take care.",
                aqi: aqi,
                category: airQuality.category
            )
        }

        if aqi <= Thresholds.aqiUnhealthySensitiveMax {
            return AirQualityDecision(
                severity: .caution,
                headline: "Unhealthy for sensitive groups",
                description: "AQI is \(aqi). Sensitive groups should limit outdoor activity.",
                aqi: aqi,
                category: airQuality.category
            )
        }

        if aqi <= Thresholds.aqiUnhealthyMax {
            return AirQualityDecision(
                severity: .warning,
                headline: "Unhealthy air — consider a mask",
                description: "AQI is \(aqi). Everyone may experience health effects.",
                aqi: aqi,
                category: airQuality.category
            )
        }

        // AQI >= aqiVeryUnhealthyMin (201+)
        return AirQualityDecision(
            severity: .danger,
            headline: "Hazardous air — mask essential",
            description: "AQI is \(aqi). Avoid outdoor activity if possible.",
            aqi: aqi,
            category: airQuality.category
        )
    }
}
