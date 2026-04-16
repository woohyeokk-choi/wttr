public enum AirQualityCategory: String, Codable, Sendable, CaseIterable {
    case good
    case moderate
    case unhealthySensitive
    case unhealthy
    case veryUnhealthy
    case hazardous

    public var aqiLowerBound: Int {
        switch self {
        case .good:               return 0
        case .moderate:           return 51
        case .unhealthySensitive: return 101
        case .unhealthy:          return 151
        case .veryUnhealthy:      return 201
        case .hazardous:          return 301
        }
    }

    public var aqiUpperBound: Int {
        switch self {
        case .good:               return 50
        case .moderate:           return 100
        case .unhealthySensitive: return 150
        case .unhealthy:          return 200
        case .veryUnhealthy:      return 300
        case .hazardous:          return Int.max
        }
    }

    public var displayName: String {
        switch self {
        case .good:               return "Good"
        case .moderate:           return "Moderate"
        case .unhealthySensitive: return "Unhealthy for Sensitive Groups"
        case .unhealthy:          return "Unhealthy"
        case .veryUnhealthy:      return "Very Unhealthy"
        case .hazardous:          return "Hazardous"
        }
    }
}
