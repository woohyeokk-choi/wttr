import Foundation

public enum CacheTTL {
    public static let currentWeather: TimeInterval = 600       // 10 min
    public static let hourlyForecast: TimeInterval = 1800      // 30 min
    public static let dailyForecast: TimeInterval = 3600       // 1 hr
    public static let yesterdayComparison: TimeInterval = 86400 // 24 hr
}

public enum CacheKey {
    public static func currentWeather(for location: LocationData) -> String { "\(location.cacheKey):currentWeather" }
    public static func hourlyForecast(for location: LocationData) -> String { "\(location.cacheKey):hourlyForecast" }
    public static func dailyForecast(for location: LocationData) -> String { "\(location.cacheKey):dailyForecast" }
    public static func yesterdayComparison(for location: LocationData) -> String { "\(location.cacheKey):yesterdayComparison" }
    public static func airQuality(for location: LocationData) -> String { "\(location.cacheKey):airQuality" }
}

private struct CacheEntry<T: Codable>: Codable {
    let value: T
    let cachedAt: Date
}

public struct WeatherCache: @unchecked Sendable {
    private let defaults: UserDefaults

    public init(suiteName: String) {
        self.defaults = UserDefaults(suiteName: suiteName) ?? .standard
    }

    public func read<T: Codable>(_ type: T.Type, forKey key: String, ttl: TimeInterval) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        guard let entry = try? JSONDecoder().decode(CacheEntry<T>.self, from: data) else { return nil }
        guard Date().timeIntervalSince(entry.cachedAt) <= ttl else { return nil }
        return entry.value
    }

    public func write<T: Codable>(_ value: T, forKey key: String) {
        let entry = CacheEntry(value: value, cachedAt: Date())
        if let data = try? JSONEncoder().encode(entry) {
            defaults.set(data, forKey: key)
        }
    }

    public func invalidateAll() {
        guard let suiteName = defaults.volatileDomainNames.first else { return }
        defaults.removePersistentDomain(forName: suiteName)
    }

    public func invalidate(key: String) {
        defaults.removeObject(forKey: key)
    }
}
