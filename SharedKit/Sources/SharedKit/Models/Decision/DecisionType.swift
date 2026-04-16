public enum DecisionType: String, Codable, Sendable, CaseIterable {
    case temperature
    case umbrella
    case sunscreen
    case sunglasses
    case airQuality

    public var iconName: String {
        switch self {
        case .temperature: return "thermometer.medium"
        case .umbrella:    return "umbrella.fill"
        case .sunscreen:   return "sun.max.trianglebadge.exclamationmark"
        case .sunglasses:  return "eyeglasses"
        case .airQuality:  return "aqi.medium"
        }
    }

    public var displayName: String {
        switch self {
        case .temperature: return "Temperature"
        case .umbrella:    return "Umbrella"
        case .sunscreen:   return "Sunscreen"
        case .sunglasses:  return "Sunglasses"
        case .airQuality:  return "Air Quality"
        }
    }
}
