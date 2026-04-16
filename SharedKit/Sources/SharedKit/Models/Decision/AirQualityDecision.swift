public struct AirQualityDecision: Decision {
    public let type: DecisionType
    public let severity: DecisionSeverity
    public let headline: String
    public let description: String
    public let icon: String
    public let aqi: Int
    public let category: AirQualityCategory

    public init(
        severity: DecisionSeverity,
        headline: String,
        description: String,
        aqi: Int,
        category: AirQualityCategory
    ) {
        self.type = .airQuality
        self.icon = "aqi.medium"
        self.severity = severity
        self.headline = headline
        self.description = description
        self.aqi = aqi
        self.category = category
    }
}
