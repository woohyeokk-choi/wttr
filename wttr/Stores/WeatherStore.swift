import SwiftUI
import SharedKit
import WidgetKit

@Observable
final class WeatherStore: @unchecked Sendable {
    var currentWeather: WeatherCondition?
    var hourlyForecast: [HourlyForecast] = []
    var dailyForecast: [DailyForecast] = []
    var yesterdayComparison: YesterdayComparison?
    var airQuality: AirQualityData?
    var decisions: [any Decision] = []
    var isLoading: Bool = false
    var error: WeatherProviderError?
    var lastFetchTime: Date?

    private let weatherProvider: any WeatherProvider
    private let decisionEngine: DecisionEngine
    private let cache: WeatherCache

    init(
        weatherProvider: any WeatherProvider,
        decisionEngine: DecisionEngine = DecisionEngine(),
        cacheSuiteName: String = "group.com.wttr.app"
    ) {
        self.weatherProvider = weatherProvider
        self.decisionEngine = decisionEngine
        self.cache = WeatherCache(suiteName: cacheSuiteName)
    }

    func fetchWeather(
        for location: LocationData,
        enabledDecisions: Set<DecisionType> = [.temperature]
    ) async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let provider = weatherProvider
            async let currentResult = provider.currentWeather(for: location)
            async let hourlyResult = provider.hourlyForecast(for: location, hours: 24)
            async let dailyResult = provider.dailyForecast(for: location, days: 7)
            async let yesterdayResult = provider.yesterdayComparison(for: location)
            async let aqResult = provider.airQuality(for: location)

            let (current, hourly, daily) = try await (currentResult, hourlyResult, dailyResult)
            let yesterday = try? await yesterdayResult
            let aq = try? await aqResult

            self.currentWeather = current
            self.hourlyForecast = hourly
            self.dailyForecast = daily
            self.yesterdayComparison = yesterday
            self.airQuality = aq
            self.lastFetchTime = Date()

            self.decisions = decisionEngine.evaluate(
                weather: current,
                yesterday: yesterday,
                airQuality: aq,
                hourlyForecast: hourly,
                enabledDecisions: enabledDecisions
            )

            cache.write(current, forKey: CacheKey.currentWeather(for: location))
            cache.write(hourly, forKey: CacheKey.hourlyForecast(for: location))
            cache.write(daily, forKey: CacheKey.dailyForecast(for: location))
            if let yesterday { cache.write(yesterday, forKey: CacheKey.yesterdayComparison(for: location)) }
            if let aq { cache.write(aq, forKey: CacheKey.airQuality(for: location)) }

            WidgetCenter.shared.reloadAllTimelines()

        } catch let weatherError as WeatherProviderError {
            self.error = weatherError
        } catch {
            self.error = .unknown(description: error.localizedDescription)
        }
    }

    func refreshIfStale(
        for location: LocationData,
        enabledDecisions: Set<DecisionType> = [.temperature]
    ) async {
        if let lastFetch = lastFetchTime, Date().timeIntervalSince(lastFetch) <= CacheTTL.currentWeather { return }
        await fetchWeather(for: location, enabledDecisions: enabledDecisions)
    }

    func clearWeather(for location: LocationData) {
        currentWeather = nil
        hourlyForecast = []
        dailyForecast = []
        yesterdayComparison = nil
        airQuality = nil
        decisions = []
        error = nil
        lastFetchTime = nil
        cache.invalidate(key: CacheKey.currentWeather(for: location))
        cache.invalidate(key: CacheKey.hourlyForecast(for: location))
        cache.invalidate(key: CacheKey.dailyForecast(for: location))
        cache.invalidate(key: CacheKey.yesterdayComparison(for: location))
        cache.invalidate(key: CacheKey.airQuality(for: location))
    }
}
