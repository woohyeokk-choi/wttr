import Foundation

public struct DailyForecast: Codable, Sendable {
    public var date: Date
    public var high: Double
    public var low: Double
    public var condition: WeatherCondition
    public var precipChance: Double
    public var sunrise: Date
    public var sunset: Date
    public var moonPhase: MoonPhase

    public init(
        date: Date,
        high: Double,
        low: Double,
        condition: WeatherCondition,
        precipChance: Double,
        sunrise: Date,
        sunset: Date,
        moonPhase: MoonPhase
    ) {
        self.date = date
        self.high = high
        self.low = low
        self.condition = condition
        self.precipChance = precipChance
        self.sunrise = sunrise
        self.sunset = sunset
        self.moonPhase = moonPhase
    }
}
