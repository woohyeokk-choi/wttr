import WidgetKit
import SharedKit

struct WttrTimelineProvider: TimelineProvider {
    typealias Entry = WeatherWidgetEntry

    private let cache = WidgetCacheReader(suiteName: "group.com.wttr.app")

    func placeholder(in context: Context) -> WeatherWidgetEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherWidgetEntry) -> Void) {
        if let entry = readCachedEntry() {
            completion(entry)
        } else {
            completion(.placeholder)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherWidgetEntry>) -> Void) {
        let entry = readCachedEntry() ?? .placeholder
        let nextRefresh = Date().addingTimeInterval(1800) // 30 minutes
        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        completion(timeline)
    }

    private func readCachedEntry() -> WeatherWidgetEntry? {
        let isProUser = cache.readBool(forKey: "subscription.isProUser")
        let unitRaw = cache.readString(forKey: "preferences.temperatureUnit") ?? "fahrenheit"
        let unit = TemperatureUnit(rawValue: unitRaw) ?? .fahrenheit
        _ = unit // used for future formatted values

        let decisionsData = cache.readData(forKey: "lastDecisions")
        let decisions: [WidgetDecision] = (try? JSONDecoder().decode([WidgetDecision].self, from: decisionsData ?? Data())) ?? []

        let lastFetchTime = cache.readDouble(forKey: "lastFetchTime")
        let fetchDate = lastFetchTime > 0 ? Date(timeIntervalSince1970: lastFetchTime) : nil
        let isStale = fetchDate == nil || Date().timeIntervalSince(fetchDate!) > 3600

        let isLocationBlocked = cache.readBool(forKey: "location.isBlocked")

        guard !decisions.isEmpty else { return nil }

        return WeatherWidgetEntry(
            date: Date(), location: "—",
            temperature: "—", feelsLike: "—",
            vsYesterday: "—", vsYesterdayDirection: .similar,
            condition: .partlyCloudy,
            decisions: decisions,
            hourlySnippet: [], weeklySnippet: [],
            isStale: isStale, lastFetchTime: fetchDate,
            isProUser: isProUser, isLocationBlocked: isLocationBlocked
        )
    }
}
