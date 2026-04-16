import Foundation

struct WidgetCacheReader: @unchecked Sendable {
    private let defaults: UserDefaults

    init(suiteName: String) {
        self.defaults = UserDefaults(suiteName: suiteName) ?? .standard
    }

    func readData(forKey key: String) -> Data? { defaults.data(forKey: key) }
    func readString(forKey key: String) -> String? { defaults.string(forKey: key) }
    func readBool(forKey key: String) -> Bool { defaults.bool(forKey: key) }
    func readDouble(forKey key: String) -> Double { defaults.double(forKey: key) }

    func isStale(threshold: TimeInterval) -> Bool {
        let lastFetch = defaults.double(forKey: "lastFetchTime")
        guard lastFetch > 0 else { return true }
        return Date().timeIntervalSince1970 - lastFetch > threshold
    }
}
