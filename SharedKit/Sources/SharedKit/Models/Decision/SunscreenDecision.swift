public enum UVCategory: String, Codable, Sendable, CaseIterable {
    case low
    case moderate
    case high
    case veryHigh

    public var uviLowerBound: Int {
        switch self {
        case .low:      return 0
        case .moderate: return 3
        case .high:     return 6
        case .veryHigh: return 8
        }
    }

    public var uviUpperBound: Int {
        switch self {
        case .low:      return 2
        case .moderate: return 5
        case .high:     return 7
        case .veryHigh: return Int.max
        }
    }
}

public struct SunscreenDecision: Decision {
    public let type: DecisionType
    public let severity: DecisionSeverity
    public let headline: String
    public let description: String
    public let icon: String
    public let uvIndex: Int
    public let uvCategory: UVCategory

    public init(
        severity: DecisionSeverity,
        headline: String,
        description: String,
        uvIndex: Int,
        uvCategory: UVCategory
    ) {
        self.type = .sunscreen
        self.icon = "sun.max.trianglebadge.exclamationmark"
        self.severity = severity
        self.headline = headline
        self.description = description
        self.uvIndex = uvIndex
        self.uvCategory = uvCategory
    }
}
