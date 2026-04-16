public enum RegionProfile: String, Codable, Sendable, CaseIterable {
    case usNortheast
    case usSouthwest
    case uk
    case nordics
    case southernEU
    case korea
    case japan

    public var thresholds: TemperatureThresholds {
        switch self {
        case .usNortheast:
            return TemperatureThresholds(freezing: -10, cold: 0, cool: 10, mild: 18)
        case .usSouthwest:
            return TemperatureThresholds(freezing: -5, cold: 5, cool: 15, mild: 22)
        case .uk:
            return TemperatureThresholds(freezing: -5, cold: 2, cool: 10, mild: 16)
        case .nordics:
            return TemperatureThresholds(freezing: -15, cold: -5, cool: 5, mild: 15)
        case .southernEU:
            return TemperatureThresholds(freezing: 0, cold: 8, cool: 15, mild: 22)
        case .korea:
            return TemperatureThresholds(freezing: -10, cold: 0, cool: 10, mild: 18)
        case .japan:
            return TemperatureThresholds(freezing: -5, cold: 2, cool: 12, mild: 20)
        }
    }

    public var displayName: String {
        switch self {
        case .usNortheast: return "US Northeast"
        case .usSouthwest: return "US Southwest"
        case .uk:          return "UK"
        case .nordics:     return "Nordics"
        case .southernEU:  return "Southern EU"
        case .korea:       return "Korea"
        case .japan:       return "Japan"
        }
    }
}
