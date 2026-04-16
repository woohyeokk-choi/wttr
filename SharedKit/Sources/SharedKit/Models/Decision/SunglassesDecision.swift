public struct SunglassesDecision: Decision {
    public let type: DecisionType
    public let severity: DecisionSeverity
    public let headline: String
    public let description: String
    public let icon: String
    public let uvIndex: Int
    public let cloudCover: Double
    public let isBright: Bool

    public init(
        severity: DecisionSeverity,
        headline: String,
        description: String,
        uvIndex: Int,
        cloudCover: Double,
        isBright: Bool
    ) {
        self.type = .sunglasses
        self.icon = "eyeglasses"
        self.severity = severity
        self.headline = headline
        self.description = description
        self.uvIndex = uvIndex
        self.cloudCover = cloudCover
        self.isBright = isBright
    }
}
