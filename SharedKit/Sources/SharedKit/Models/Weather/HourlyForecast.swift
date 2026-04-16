import Foundation

public struct HourlyForecast: Codable, Sendable {
    public var hour: Date
    public var condition: WeatherCondition
    public var precipitationChance: Double
    public var precipitationType: PrecipitationType
    public var precipitationAmount: Double

    public init(
        hour: Date,
        condition: WeatherCondition,
        precipitationChance: Double,
        precipitationType: PrecipitationType,
        precipitationAmount: Double
    ) {
        self.hour = hour
        self.condition = condition
        self.precipitationChance = precipitationChance
        self.precipitationType = precipitationType
        self.precipitationAmount = precipitationAmount
    }
}
