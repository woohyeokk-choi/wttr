extension DecisionEngine {
    func evaluateSunglasses(weather: WeatherCondition) -> SunglassesDecision {
        let uv = weather.uvIndex
        let cloud = weather.cloudCover
        let highUV = uv >= Thresholds.uvThreshold
        let clearSky = cloud < Thresholds.cloudThreshold

        if highUV && clearSky {
            return SunglassesDecision(
                severity: .warning,
                headline: "Bright & clear — bring sunglasses",
                description: "UV index is \(uv) with \(Int(cloud * 100))% cloud cover.",
                uvIndex: uv,
                cloudCover: cloud,
                isBright: true
            )
        }

        if highUV && !clearSky {
            return SunglassesDecision(
                severity: .caution,
                headline: "Partly cloudy — sunglasses optional",
                description: "UV index is \(uv) but clouds reduce glare.",
                uvIndex: uv,
                cloudCover: cloud,
                isBright: false
            )
        }

        if !highUV && clearSky {
            return SunglassesDecision(
                severity: .safe,
                headline: "Overcast or low UV — sunglasses optional",
                description: "UV index is \(uv). Low risk of eye strain.",
                uvIndex: uv,
                cloudCover: cloud,
                isBright: false
            )
        }

        // !highUV && !clearSky
        return SunglassesDecision(
            severity: .safe,
            headline: "Overcast — sunglasses not needed",
            description: "UV index is \(uv) with heavy cloud cover.",
            uvIndex: uv,
            cloudCover: cloud,
            isBright: false
        )
    }
}
