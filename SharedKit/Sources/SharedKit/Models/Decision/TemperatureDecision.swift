public enum TemperatureDirection: String, Codable, Sendable {
    case warmer
    case colder
    case similar
}

public struct TemperatureDecision: Decision {
    public let type: DecisionType
    public let severity: DecisionSeverity
    public let headline: String
    public let description: String
    public let icon: String
    public let diff: Double
    public let direction: TemperatureDirection
    public let todayHigh: Double
    public let yesterdayHigh: Double

    public init(
        severity: DecisionSeverity,
        headline: String,
        description: String,
        diff: Double,
        direction: TemperatureDirection,
        todayHigh: Double,
        yesterdayHigh: Double
    ) {
        self.type = .temperature
        self.icon = "thermometer.medium"
        self.severity = severity
        self.headline = headline
        self.description = description
        self.diff = diff
        self.direction = direction
        self.todayHigh = todayHigh
        self.yesterdayHigh = yesterdayHigh
    }
}
