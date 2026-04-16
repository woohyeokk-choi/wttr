extension DecisionEngine {
    func evaluateSunscreen(weather: WeatherCondition) -> SunscreenDecision {
        let uv = weather.uvIndex

        if Thresholds.uvLow.contains(uv) {
            return SunscreenDecision(
                severity: .safe,
                headline: "Low UV — no sunscreen needed",
                description: "UV index is \(uv). Sun protection not necessary.",
                uvIndex: uv,
                uvCategory: .low
            )
        }

        if Thresholds.uvModerate.contains(uv) {
            return SunscreenDecision(
                severity: .caution,
                headline: "Moderate UV — sunscreen recommended",
                description: "UV index is \(uv). Consider applying sunscreen.",
                uvIndex: uv,
                uvCategory: .moderate
            )
        }

        if Thresholds.uvHigh.contains(uv) {
            return SunscreenDecision(
                severity: .warning,
                headline: "High UV — apply sunscreen",
                description: "UV index is \(uv). Sunscreen and shade recommended.",
                uvIndex: uv,
                uvCategory: .high
            )
        }

        // UV >= uvVeryHigh (8+)
        return SunscreenDecision(
            severity: .danger,
            headline: "Very high UV — sunscreen essential",
            description: "UV index is \(uv). Reapply sunscreen frequently.",
            uvIndex: uv,
            uvCategory: .veryHigh
        )
    }
}
