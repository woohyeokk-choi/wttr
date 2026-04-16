import Foundation
@testable import SharedKit

public final class MockWeatherProvider: WeatherProvider, @unchecked Sendable {
    // Configuration
    public var errorToThrow: WeatherProviderError?
    public var simulatedDelay: TimeInterval = 0

    // Stubbed return values
    public var stubbedCurrentWeather: WeatherCondition
    public var stubbedHourlyForecast: [HourlyForecast]
    public var stubbedDailyForecast: [DailyForecast]
    public var stubbedYesterdayComparison: YesterdayComparison
    public var stubbedAirQuality: AirQualityData

    // Call tracking
    public var currentWeatherCallCount = 0
    public var hourlyForecastCallCount = 0
    public var dailyForecastCallCount = 0
    public var yesterdayComparisonCallCount = 0
    public var airQualityCallCount = 0

    public init() {
        let now = Date()

        self.stubbedCurrentWeather = WeatherCondition(
            temperature: 18.5,
            feelsLike: 16.2,
            humidity: 0.65,
            windSpeed: 14.0,
            windDirection: 270.0,
            cloudCover: 0.3,
            uvIndex: 6,
            condition: .partlyCloudy,
            icon: "cloud.sun.fill",
            date: now
        )

        self.stubbedHourlyForecast = (0..<24).map { i in
            let hour = Calendar.current.date(byAdding: .hour, value: i, to: now)!
            let temp = 18.5 - Double(i) * 0.5
            let isRainy = i >= 15 && i <= 17
            return HourlyForecast(
                hour: hour,
                condition: WeatherCondition(
                    temperature: temp,
                    feelsLike: temp - 2,
                    humidity: 0.65,
                    windSpeed: 14,
                    windDirection: 270,
                    cloudCover: 0.3,
                    uvIndex: max(0, 6 - i / 2),
                    condition: .partlyCloudy,
                    icon: "cloud.sun.fill",
                    date: hour
                ),
                precipitationChance: isRainy ? 0.70 : 0.10,
                precipitationType: isRainy ? .rain : .none,
                precipitationAmount: isRainy ? 2.5 : 0
            )
        }

        self.stubbedDailyForecast = (0..<7).map { i in
            let day = Calendar.current.date(byAdding: .day, value: i, to: now)!
            return DailyForecast(
                date: day,
                high: 22 + Double(i),
                low: 12 + Double(i),
                condition: WeatherCondition(
                    temperature: 18,
                    feelsLike: 16,
                    humidity: 0.5,
                    windSpeed: 10,
                    windDirection: 180,
                    cloudCover: 0.4,
                    uvIndex: 5,
                    condition: .partlyCloudy,
                    icon: "cloud.sun.fill",
                    date: day
                ),
                precipChance: i == 1 ? 0.4 : 0.1,
                sunrise: Calendar.current.date(bySettingHour: 6, minute: 30, second: 0, of: day)!,
                sunset: Calendar.current.date(bySettingHour: 19, minute: 45, second: 0, of: day)!,
                moonPhase: .waxingCrescent
            )
        }

        self.stubbedYesterdayComparison = YesterdayComparison(
            high: 21.0,
            low: 12.5,
            fetchedAt: now
        )

        self.stubbedAirQuality = AirQualityData(
            aqi: 29,
            category: .good,
            primaryPollutant: "PM2.5",
            pm25: 12.0,
            pm10: 18.0
        )
    }

    public func currentWeather(for location: LocationData) async throws -> WeatherCondition {
        currentWeatherCallCount += 1
        if let error = errorToThrow { throw error }
        if simulatedDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(simulatedDelay * 1_000_000_000))
        }
        return stubbedCurrentWeather
    }

    public func hourlyForecast(for location: LocationData, hours: Int) async throws -> [HourlyForecast] {
        hourlyForecastCallCount += 1
        if let error = errorToThrow { throw error }
        if simulatedDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(simulatedDelay * 1_000_000_000))
        }
        return Array(stubbedHourlyForecast.prefix(hours))
    }

    public func dailyForecast(for location: LocationData, days: Int) async throws -> [DailyForecast] {
        dailyForecastCallCount += 1
        if let error = errorToThrow { throw error }
        if simulatedDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(simulatedDelay * 1_000_000_000))
        }
        return Array(stubbedDailyForecast.prefix(days))
    }

    public func yesterdayComparison(for location: LocationData) async throws -> YesterdayComparison {
        yesterdayComparisonCallCount += 1
        if let error = errorToThrow { throw error }
        if simulatedDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(simulatedDelay * 1_000_000_000))
        }
        return stubbedYesterdayComparison
    }

    public func airQuality(for location: LocationData) async throws -> AirQualityData {
        airQualityCallCount += 1
        if let error = errorToThrow { throw error }
        if simulatedDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(simulatedDelay * 1_000_000_000))
        }
        return stubbedAirQuality
    }
}
