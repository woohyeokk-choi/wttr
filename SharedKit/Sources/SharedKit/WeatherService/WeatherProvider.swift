import Foundation

/// Protocol-first weather data contract.
public protocol WeatherProvider: Sendable {
    func currentWeather(for location: LocationData) async throws -> WeatherCondition
    func hourlyForecast(for location: LocationData, hours: Int) async throws -> [HourlyForecast]
    func dailyForecast(for location: LocationData, days: Int) async throws -> [DailyForecast]
    func yesterdayComparison(for location: LocationData) async throws -> YesterdayComparison
    func airQuality(for location: LocationData) async throws -> AirQualityData
}
