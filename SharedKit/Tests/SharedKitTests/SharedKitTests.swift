import XCTest
@testable import SharedKit

final class SharedKitTests: XCTestCase {
    func testVersionExists() {
        XCTAssertEqual(SharedKitVersion.current, "1.0.0")
    }

    // MARK: - Fixture Loading

    func testFixtureCurrentWeather() throws {
        let data = try loadFixture("current-weather")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let weather = try decoder.decode(WeatherCondition.self, from: data)
        XCTAssertEqual(weather.temperature, 18.5)
        XCTAssertEqual(weather.feelsLike, 16.2)
        XCTAssertEqual(weather.humidity, 0.65)
        XCTAssertEqual(weather.uvIndex, 6)
        XCTAssertEqual(weather.condition, .partlyCloudy)
        XCTAssertEqual(weather.icon, "cloud.sun.fill")
    }

    func testFixtureYesterdayComparison() throws {
        let data = try loadFixture("yesterday-comparison")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let comparison = try decoder.decode(YesterdayComparison.self, from: data)
        XCTAssertEqual(comparison.high, 21.0)
        XCTAssertEqual(comparison.low, 12.5)
    }

    func testFixtureAirQuality() throws {
        let data = try loadFixture("air-quality")
        let decoder = JSONDecoder()
        let airQuality = try decoder.decode(AirQualityData.self, from: data)
        XCTAssertEqual(airQuality.aqi, 29)
        XCTAssertEqual(airQuality.category, .good)
        XCTAssertEqual(airQuality.primaryPollutant, "PM2.5")
        XCTAssertEqual(airQuality.pm25, 12.0)
        XCTAssertEqual(airQuality.pm10, 18.0)
    }

    func testFixtureHourlyForecast() throws {
        let data = try loadFixture("hourly-forecast")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let forecasts = try decoder.decode([HourlyForecast].self, from: data)
        XCTAssertEqual(forecasts.count, 24)
        // Verify at least one hour with precipitationChance > 0.40 for umbrella evaluator
        let rainyHours = forecasts.filter { $0.precipitationChance > 0.40 }
        XCTAssertFalse(rainyHours.isEmpty, "Expected at least one hour with precipitationChance > 0.40")
    }

    func testFixtureDailyForecast() throws {
        let data = try loadFixture("daily-forecast")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let forecasts = try decoder.decode([DailyForecast].self, from: data)
        XCTAssertEqual(forecasts.count, 7)
        XCTAssertEqual(forecasts[0].high, 22.0)
        XCTAssertEqual(forecasts[0].low, 12.0)
    }

    // MARK: - Helper

    func loadFixture(_ name: String) throws -> Data {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json") else {
            throw NSError(
                domain: "test",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Fixture \(name) not found"]
            )
        }
        return try Data(contentsOf: url)
    }
}
