import Foundation

public struct WeatherCondition: Codable, Sendable {
    public var temperature: Double
    public var feelsLike: Double
    public var humidity: Double
    public var windSpeed: Double
    public var windDirection: Double
    public var cloudCover: Double
    public var uvIndex: Int
    public var condition: WeatherConditionType
    public var icon: String
    public var date: Date

    public init(
        temperature: Double,
        feelsLike: Double,
        humidity: Double,
        windSpeed: Double,
        windDirection: Double,
        cloudCover: Double,
        uvIndex: Int,
        condition: WeatherConditionType,
        icon: String,
        date: Date
    ) {
        self.temperature = temperature
        self.feelsLike = feelsLike
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.windDirection = windDirection
        self.cloudCover = cloudCover
        self.uvIndex = uvIndex
        self.condition = condition
        self.icon = icon
        self.date = date
    }
}
