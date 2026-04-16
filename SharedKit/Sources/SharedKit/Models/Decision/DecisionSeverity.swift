public enum DecisionSeverity: String, Codable, Sendable, CaseIterable {
    case safe
    case caution
    case warning
    case danger

    public var colorName: String {
        switch self {
        case .safe:    return "Safe"
        case .caution: return "Caution"
        case .warning: return "Warning"
        case .danger:  return "Danger"
        }
    }

    public var displayName: String {
        switch self {
        case .safe:    return "Safe"
        case .caution: return "Caution"
        case .warning: return "Warning"
        case .danger:  return "Danger"
        }
    }
}
