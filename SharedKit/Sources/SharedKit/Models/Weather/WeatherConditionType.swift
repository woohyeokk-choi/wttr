public enum WeatherConditionType: String, Codable, Sendable, CaseIterable {
    case clear
    case partlyCloudy
    case cloudy
    case rain
    case thunderstorm
    case snow
    case fog
    case clearNight
    case cloudyNight
    case partlyCloudyNight
    case drizzle
    case heavyRain
    case sleet
    case blizzard
    case haze
    case windy

    public var sfSymbolName: String {
        switch self {
        case .clear:             return "sun.max.fill"
        case .partlyCloudy:      return "cloud.sun.fill"
        case .cloudy:            return "cloud.fill"
        case .rain:              return "cloud.rain.fill"
        case .thunderstorm:      return "cloud.bolt.rain.fill"
        case .snow:              return "cloud.snow.fill"
        case .fog:               return "cloud.fog.fill"
        case .clearNight:        return "moon.fill"
        case .cloudyNight:       return "cloud.moon.fill"
        case .partlyCloudyNight: return "cloud.moon.fill"
        case .drizzle:           return "cloud.drizzle.fill"
        case .heavyRain:         return "cloud.heavyrain.fill"
        case .sleet:             return "cloud.sleet.fill"
        case .blizzard:          return "wind.snow"
        case .haze:              return "sun.haze.fill"
        case .windy:             return "wind"
        }
    }

    public var displayName: String {
        switch self {
        case .clear:             return "Clear"
        case .partlyCloudy:      return "Partly Cloudy"
        case .cloudy:            return "Cloudy"
        case .rain:              return "Rain"
        case .thunderstorm:      return "Thunderstorm"
        case .snow:              return "Snow"
        case .fog:               return "Fog"
        case .clearNight:        return "Clear Night"
        case .cloudyNight:       return "Cloudy Night"
        case .partlyCloudyNight: return "Partly Cloudy Night"
        case .drizzle:           return "Drizzle"
        case .heavyRain:         return "Heavy Rain"
        case .sleet:             return "Sleet"
        case .blizzard:          return "Blizzard"
        case .haze:              return "Haze"
        case .windy:             return "Windy"
        }
    }
}
