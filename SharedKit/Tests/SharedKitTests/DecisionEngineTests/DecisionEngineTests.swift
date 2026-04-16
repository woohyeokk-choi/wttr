import XCTest
@testable import SharedKit

// MARK: - Test Helpers

private let referenceDate = Date(timeIntervalSince1970: 1_700_000_000) // 2023-11-14 ~22:13 UTC

private func makeWeather(
    temperature: Double = 18.0,
    uvIndex: Int = 5,
    cloudCover: Double = 0.3
) -> WeatherCondition {
    WeatherCondition(
        temperature: temperature,
        feelsLike: temperature - 2.0,
        humidity: 0.50,
        windSpeed: 10.0,
        windDirection: 180.0,
        cloudCover: cloudCover,
        uvIndex: uvIndex,
        condition: .clear,
        icon: "sun.max.fill",
        date: referenceDate
    )
}

private func makeHourlyForecast(
    count: Int = 24,
    precipChance: Double = 0.10,
    startDate: Date = referenceDate
) -> [HourlyForecast] {
    (0..<count).map { i in
        let hour = startDate.addingTimeInterval(Double(i) * 3600)
        return HourlyForecast(
            hour: hour,
            condition: makeWeather(),
            precipitationChance: precipChance,
            precipitationType: precipChance > 0.20 ? .rain : .none,
            precipitationAmount: precipChance > 0.20 ? 2.0 : 0.0
        )
    }
}

private func makeHourlyWithRain(
    rainHours: Range<Int>,
    precipChance: Double = 0.70,
    totalCount: Int = 24,
    startDate: Date = referenceDate
) -> [HourlyForecast] {
    (0..<totalCount).map { i in
        let hour = startDate.addingTimeInterval(Double(i) * 3600)
        let isRain = rainHours.contains(i)
        return HourlyForecast(
            hour: hour,
            condition: makeWeather(),
            precipitationChance: isRain ? precipChance : 0.05,
            precipitationType: isRain ? .rain : .none,
            precipitationAmount: isRain ? 5.0 : 0.0
        )
    }
}

private func makeYesterday(high: Double) -> YesterdayComparison {
    YesterdayComparison(
        high: high,
        low: high - 8.0,
        fetchedAt: referenceDate.addingTimeInterval(-86400)
    )
}

private func makeAirQuality(aqi: Int, category: AirQualityCategory) -> AirQualityData {
    AirQualityData(
        aqi: aqi,
        category: category,
        primaryPollutant: "PM2.5",
        pm25: Double(aqi) * 0.3,
        pm10: Double(aqi) * 0.5
    )
}

// MARK: - Temperature Evaluator Tests

final class TemperatureEvaluatorTests: XCTestCase {

    private let engine = DecisionEngine()

    // T-1: Similar temperature (diff <= 2) returns safe / similar
    func test_similarTemperature_returnsSafeAndSimilar() {
        let weather = makeWeather(temperature: 20.0)
        let yesterday = makeYesterday(high: 19.0) // diff = +1.0

        let result = engine.evaluateTemperature(weather: weather, yesterday: yesterday)

        XCTAssertEqual(result.severity, .safe)
        XCTAssertEqual(result.direction, .similar)
        XCTAssertEqual(result.diff, 1.0, accuracy: 0.01)
        XCTAssertTrue(result.headline.contains("same"), "Expected headline to contain 'same', got: \(result.headline)")
    }

    // T-2: Significantly colder (diff = -7) returns warning / colder
    func test_significantlyColder_returnsWarningAndColder() {
        let weather = makeWeather(temperature: 13.0)
        let yesterday = makeYesterday(high: 20.0) // diff = -7.0

        let result = engine.evaluateTemperature(weather: weather, yesterday: yesterday)

        XCTAssertEqual(result.severity, .warning)
        XCTAssertEqual(result.direction, .colder)
        XCTAssertTrue(result.headline.contains("colder"), "Expected headline to contain 'colder', got: \(result.headline)")
        XCTAssertTrue(result.headline.contains("layer up"), "Expected headline to contain 'layer up', got: \(result.headline)")
    }

    // T-3: Yesterday data unavailable (nil) returns safe / similar with "unavailable"
    func test_yesterdayNil_returnsSafeWithUnavailableHeadline() {
        let weather = makeWeather(temperature: 22.0)

        let result = engine.evaluateTemperature(weather: weather, yesterday: nil)

        XCTAssertEqual(result.severity, .safe)
        XCTAssertEqual(result.direction, .similar)
        XCTAssertTrue(result.headline.contains("unavailable"), "Expected headline to contain 'unavailable', got: \(result.headline)")
    }

    // T-4: Significantly warmer (diff = +7) returns caution / warmer
    func test_significantlyWarmer_returnsCautionAndWarmer() {
        let weather = makeWeather(temperature: 27.0)
        let yesterday = makeYesterday(high: 20.0) // diff = +7.0

        let result = engine.evaluateTemperature(weather: weather, yesterday: yesterday)

        XCTAssertEqual(result.severity, .caution)
        XCTAssertEqual(result.direction, .warmer)
        XCTAssertTrue(result.headline.contains("warmer"), "Expected headline to contain 'warmer', got: \(result.headline)")
        XCTAssertTrue(result.headline.contains("dress lighter"), "Expected headline to contain 'dress lighter', got: \(result.headline)")
    }
}

// MARK: - Umbrella Evaluator Tests

final class UmbrellaEvaluatorTests: XCTestCase {

    private let engine = DecisionEngine()

    // U-1: No rain (all precip 0.10) returns safe, "No rain expected", rainStartTime nil
    func test_noRain_returnsSafeWithNoRainHeadline() {
        let forecast = makeHourlyForecast(count: 24, precipChance: 0.10)

        let result = engine.evaluateUmbrella(hourlyForecast: forecast)

        XCTAssertEqual(result.severity, .safe)
        XCTAssertEqual(result.headline, "No rain expected")
        XCTAssertNil(result.rainStartTime)
    }

    // U-2: Rain mid-afternoon (hours 15-17 at 0.70) returns warning, rainStartTime = hour[15]
    func test_rainMidAfternoon_returnsWarningWithRainStartTime() {
        let forecast = makeHourlyWithRain(rainHours: 15..<18, precipChance: 0.70)

        let result = engine.evaluateUmbrella(hourlyForecast: forecast)

        XCTAssertEqual(result.severity, .warning)
        let expectedStart = referenceDate.addingTimeInterval(Double(15) * 3600)
        XCTAssertEqual(result.rainStartTime, expectedStart)
        XCTAssertTrue(result.headline.contains("umbrella"), "Expected headline to contain 'umbrella', got: \(result.headline)")
    }

    // U-3: Rain imminent (hour[1] at 0.80) returns danger, headline contains "soon"
    func test_rainImminent_returnsDangerWithSoonHeadline() {
        let forecast = makeHourlyWithRain(rainHours: 1..<3, precipChance: 0.80)

        let result = engine.evaluateUmbrella(hourlyForecast: forecast)

        XCTAssertEqual(result.severity, .danger)
        XCTAssertTrue(result.headline.contains("soon"), "Expected headline to contain 'soon', got: \(result.headline)")
        XCTAssertNotNil(result.rainStartTime)
    }

    // U-4: Empty forecast returns safe, "No forecast data"
    func test_emptyForecast_returnsSafeWithNoForecastData() {
        let result = engine.evaluateUmbrella(hourlyForecast: [])

        XCTAssertEqual(result.severity, .safe)
        XCTAssertEqual(result.headline, "No forecast data")
        XCTAssertNil(result.rainStartTime)
    }

    // U-5: Caution band (all 0.30) returns caution, "Slight chance", rainStartTime nil
    func test_slightChance_returnsCautionWithSlightChanceHeadline() {
        let forecast = makeHourlyForecast(count: 24, precipChance: 0.30)

        let result = engine.evaluateUmbrella(hourlyForecast: forecast)

        XCTAssertEqual(result.severity, .caution)
        XCTAssertTrue(result.headline.contains("Slight chance"), "Expected headline to contain 'Slight chance', got: \(result.headline)")
        XCTAssertNil(result.rainStartTime)
    }
}

// MARK: - Sunscreen Evaluator Tests

final class SunscreenEvaluatorTests: XCTestCase {

    private let engine = DecisionEngine()

    // S-1: UV=1 returns safe, low
    func test_uvLow_returnsSafeAndLowCategory() {
        let weather = makeWeather(uvIndex: 1)

        let result = engine.evaluateSunscreen(weather: weather)

        XCTAssertEqual(result.severity, .safe)
        XCTAssertEqual(result.uvCategory, .low)
        XCTAssertTrue(result.headline.contains("Low UV"), "Expected headline to contain 'Low UV', got: \(result.headline)")
    }

    // S-2: UV=7 returns warning, high
    func test_uvHigh_returnsWarningAndHighCategory() {
        let weather = makeWeather(uvIndex: 7)

        let result = engine.evaluateSunscreen(weather: weather)

        XCTAssertEqual(result.severity, .warning)
        XCTAssertEqual(result.uvCategory, .high)
        XCTAssertTrue(result.headline.contains("High UV"), "Expected headline to contain 'High UV', got: \(result.headline)")
    }

    // S-3: UV=10 returns danger, veryHigh
    func test_uvVeryHigh_returnsDangerAndVeryHighCategory() {
        let weather = makeWeather(uvIndex: 10)

        let result = engine.evaluateSunscreen(weather: weather)

        XCTAssertEqual(result.severity, .danger)
        XCTAssertEqual(result.uvCategory, .veryHigh)
        XCTAssertTrue(result.headline.contains("Very high UV"), "Expected headline to contain 'Very high UV', got: \(result.headline)")
    }

    // S-4: UV=3 boundary returns caution, moderate
    func test_uvModerateBoundary_returnsCautionAndModerateCategory() {
        let weather = makeWeather(uvIndex: 3)

        let result = engine.evaluateSunscreen(weather: weather)

        XCTAssertEqual(result.severity, .caution)
        XCTAssertEqual(result.uvCategory, .moderate)
        XCTAssertTrue(result.headline.contains("Moderate UV"), "Expected headline to contain 'Moderate UV', got: \(result.headline)")
    }

    // S-5: UV=8 boundary returns danger, veryHigh
    func test_uvVeryHighBoundary_returnsDangerAndVeryHighCategory() {
        let weather = makeWeather(uvIndex: 8)

        let result = engine.evaluateSunscreen(weather: weather)

        XCTAssertEqual(result.severity, .danger)
        XCTAssertEqual(result.uvCategory, .veryHigh)
    }
}

// MARK: - Sunglasses Evaluator Tests

final class SunglassesEvaluatorTests: XCTestCase {

    private let engine = DecisionEngine()

    // G-1: UV=6, cloud=0.20 -> warning, isBright=true (highUV=true, clearSky=true)
    func test_highUVClearSky_returnsWarningAndBright() {
        let weather = makeWeather(uvIndex: 6, cloudCover: 0.20)

        let result = engine.evaluateSunglasses(weather: weather)

        XCTAssertEqual(result.severity, .warning)
        XCTAssertTrue(result.isBright)
        XCTAssertTrue(result.headline.contains("Bright"), "Expected headline to contain 'Bright', got: \(result.headline)")
    }

    // G-2: UV=6, cloud=0.70 -> caution, isBright=false (highUV=true, clearSky=false)
    func test_highUVCloudy_returnsCautionAndNotBright() {
        let weather = makeWeather(uvIndex: 6, cloudCover: 0.70)

        let result = engine.evaluateSunglasses(weather: weather)

        XCTAssertEqual(result.severity, .caution)
        XCTAssertFalse(result.isBright)
        XCTAssertTrue(result.headline.contains("Partly cloudy"), "Expected headline to contain 'Partly cloudy', got: \(result.headline)")
    }

    // G-3: UV=1, cloud=0.80 -> safe, isBright=false (lowUV, not clearSky)
    func test_lowUVOvercast_returnsSafeAndNotBright() {
        let weather = makeWeather(uvIndex: 1, cloudCover: 0.80)

        let result = engine.evaluateSunglasses(weather: weather)

        XCTAssertEqual(result.severity, .safe)
        XCTAssertFalse(result.isBright)
        XCTAssertTrue(result.headline.contains("Overcast"), "Expected headline to contain 'Overcast', got: \(result.headline)")
    }

    // G-4: UV=5, cloud=0.50 boundary -> caution, isBright=false (highUV=true since 5>=4, clearSky=false since 0.50 is NOT < 0.50)
    func test_boundaryCloudCover_returnsCautionAndNotBright() {
        let weather = makeWeather(uvIndex: 5, cloudCover: 0.50)

        let result = engine.evaluateSunglasses(weather: weather)

        XCTAssertEqual(result.severity, .caution)
        XCTAssertFalse(result.isBright)
    }
}

// MARK: - Air Quality Evaluator Tests

final class AirQualityEvaluatorTests: XCTestCase {

    private let engine = DecisionEngine()

    // A-1: AQI=25 returns safe
    func test_goodAirQuality_returnsSafe() {
        let aq = makeAirQuality(aqi: 25, category: .good)

        let result = engine.evaluateAirQuality(airQuality: aq)

        XCTAssertEqual(result.severity, .safe)
        XCTAssertTrue(result.headline.contains("good"), "Expected headline to contain 'good', got: \(result.headline)")
    }

    // A-2: AQI=160 returns warning
    func test_unhealthyAirQuality_returnsWarning() {
        let aq = makeAirQuality(aqi: 160, category: .unhealthy)

        let result = engine.evaluateAirQuality(airQuality: aq)

        XCTAssertEqual(result.severity, .warning)
        XCTAssertTrue(result.headline.contains("mask"), "Expected headline to contain 'mask', got: \(result.headline)")
    }

    // A-3: AQI=320 returns danger
    func test_hazardousAirQuality_returnsDanger() {
        let aq = makeAirQuality(aqi: 320, category: .hazardous)

        let result = engine.evaluateAirQuality(airQuality: aq)

        XCTAssertEqual(result.severity, .danger)
        XCTAssertTrue(result.headline.contains("Hazardous"), "Expected headline to contain 'Hazardous', got: \(result.headline)")
    }

    // A-4: nil airQuality -> no AirQualityDecision in results
    func test_nilAirQuality_excludesAirQualityDecision() {
        let weather = makeWeather()
        let forecast = makeHourlyForecast()

        let results = DecisionEngine().evaluate(
            weather: weather,
            yesterday: makeYesterday(high: 18.0),
            airQuality: nil,
            hourlyForecast: forecast,
            enabledDecisions: Set(DecisionType.allCases)
        )

        let airQualityDecisions = results.filter { $0.type == .airQuality }
        XCTAssertTrue(airQualityDecisions.isEmpty, "Expected no air quality decision when data is nil")
    }
}

// MARK: - Priority Sorting Tests

final class DecisionPrioritySortingTests: XCTestCase {

    // P-1: Heavy rain day -> umbrella sorts above sunscreen
    func test_heavyRainDay_umbrellaSortsAboveSunscreen() {
        let weather = makeWeather(temperature: 20.0, uvIndex: 3, cloudCover: 0.80)
        let forecast = makeHourlyWithRain(rainHours: 0..<12, precipChance: 0.90)

        let results = DecisionEngine().evaluate(
            weather: weather,
            yesterday: makeYesterday(high: 20.0),
            airQuality: nil,
            hourlyForecast: forecast,
            enabledDecisions: Set(DecisionType.allCases)
        )

        // Temperature is always first
        XCTAssertEqual(results[0].type, .temperature)

        // Among the rest, find umbrella and sunscreen positions
        let umbrellaIndex = results.firstIndex(where: { $0.type == .umbrella })!
        let sunscreenIndex = results.firstIndex(where: { $0.type == .sunscreen })!
        XCTAssertTrue(umbrellaIndex < sunscreenIndex, "Expected umbrella (index \(umbrellaIndex)) to sort before sunscreen (index \(sunscreenIndex))")
    }

    // P-2: Clear high-UV day -> sunscreen sorts above umbrella
    func test_clearHighUVDay_sunscreenSortsAboveUmbrella() {
        let weather = makeWeather(temperature: 20.0, uvIndex: 10, cloudCover: 0.10)
        let forecast = makeHourlyForecast(count: 24, precipChance: 0.05)

        let results = DecisionEngine().evaluate(
            weather: weather,
            yesterday: makeYesterday(high: 20.0),
            airQuality: nil,
            hourlyForecast: forecast,
            enabledDecisions: Set(DecisionType.allCases)
        )

        XCTAssertEqual(results[0].type, .temperature)

        let umbrellaIndex = results.firstIndex(where: { $0.type == .umbrella })!
        let sunscreenIndex = results.firstIndex(where: { $0.type == .sunscreen })!
        XCTAssertTrue(sunscreenIndex < umbrellaIndex, "Expected sunscreen (index \(sunscreenIndex)) to sort before umbrella (index \(umbrellaIndex))")
    }

    // P-3: Hazardous AQI -> airQuality sorts first among non-temperature
    func test_hazardousAQI_airQualitySortsFirstAmongNonTemp() {
        let weather = makeWeather(temperature: 20.0, uvIndex: 3, cloudCover: 0.50)
        let forecast = makeHourlyForecast(count: 24, precipChance: 0.05)
        let aq = makeAirQuality(aqi: 320, category: .hazardous)

        let results = DecisionEngine().evaluate(
            weather: weather,
            yesterday: makeYesterday(high: 20.0),
            airQuality: aq,
            hourlyForecast: forecast,
            enabledDecisions: Set(DecisionType.allCases)
        )

        XCTAssertEqual(results[0].type, .temperature)

        // airQuality score = min(320/200, 1.0) = 1.0, which is the max
        // umbrella score = 0.05, sunscreen score = 3/11 ~ 0.27, sunglasses score = 0.2
        // So airQuality should be second (first among non-temperature)
        XCTAssertEqual(results[1].type, .airQuality, "Expected air quality to sort first among non-temperature decisions")
    }
}

// MARK: - Integration Tests via DecisionEngine.evaluate

final class DecisionEngineIntegrationTests: XCTestCase {

    // I-1: All decisions are produced when all types are enabled
    func test_evaluateReturnsAllDecisionTypesWhenEnabled() {
        let weather = makeWeather(temperature: 25.0, uvIndex: 6, cloudCover: 0.30)
        let yesterday = makeYesterday(high: 20.0)
        let forecast = makeHourlyWithRain(rainHours: 10..<14, precipChance: 0.60)
        let aq = makeAirQuality(aqi: 80, category: .moderate)

        let results = DecisionEngine().evaluate(
            weather: weather,
            yesterday: yesterday,
            airQuality: aq,
            hourlyForecast: forecast,
            enabledDecisions: Set(DecisionType.allCases)
        )

        let types = Set(results.map(\.type))
        XCTAssertEqual(types, Set(DecisionType.allCases))
        XCTAssertEqual(results.count, 5)
    }

    // I-2: Temperature is always first in results
    func test_temperatureAlwaysFirst() {
        let weather = makeWeather()
        let forecast = makeHourlyForecast()

        let results = DecisionEngine().evaluate(
            weather: weather,
            yesterday: makeYesterday(high: 18.0),
            airQuality: makeAirQuality(aqi: 300, category: .veryUnhealthy),
            hourlyForecast: forecast,
            enabledDecisions: Set(DecisionType.allCases)
        )

        XCTAssertEqual(results.first?.type, .temperature)
    }

    // I-3: Temperature is evaluated even when not in enabledDecisions
    func test_temperatureEvaluatedEvenWhenNotExplicitlyEnabled() {
        let weather = makeWeather()
        let forecast = makeHourlyForecast()

        let results = DecisionEngine().evaluate(
            weather: weather,
            yesterday: makeYesterday(high: 18.0),
            airQuality: nil,
            hourlyForecast: forecast,
            enabledDecisions: [.umbrella]
        )

        let types = results.map(\.type)
        XCTAssertTrue(types.contains(.temperature), "Temperature should always be evaluated")
        XCTAssertTrue(types.contains(.umbrella))
        XCTAssertFalse(types.contains(.sunscreen))
    }
}
