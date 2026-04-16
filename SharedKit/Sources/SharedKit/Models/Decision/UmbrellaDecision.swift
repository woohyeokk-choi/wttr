import Foundation

public struct UmbrellaDecision: Decision {
    public let type: DecisionType
    public let severity: DecisionSeverity
    public let headline: String
    public let description: String
    public let icon: String
    public let rainStartTime: Date?
    public let rainEndTime: Date?
    public let maxPrecipChance: Double
    public let precipitationType: PrecipitationType

    public init(
        severity: DecisionSeverity,
        headline: String,
        description: String,
        rainStartTime: Date?,
        rainEndTime: Date?,
        maxPrecipChance: Double,
        precipitationType: PrecipitationType
    ) {
        self.type = .umbrella
        self.icon = "umbrella.fill"
        self.severity = severity
        self.headline = headline
        self.description = description
        self.rainStartTime = rainStartTime
        self.rainEndTime = rainEndTime
        self.maxPrecipChance = maxPrecipChance
        self.precipitationType = precipitationType
    }
}
