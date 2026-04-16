import SwiftUI
import SharedKit

@Observable
final class PreferencesStore: @unchecked Sendable {
    var enabledDecisions: Set<DecisionType> = [.temperature]
    var temperatureUnit: TemperatureUnit = .fahrenheit
    var notificationTime: Date?
    var notificationsEnabled: Bool = false
    var region: RegionProfile?
    var hasCompletedOnboarding: Bool = false

    private let defaults: UserDefaults

    init(suiteName: String = "group.com.wttr.app") {
        self.defaults = UserDefaults(suiteName: suiteName) ?? .standard
        load()
    }

    func save() {
        let decisionsRaw = enabledDecisions.map { $0.rawValue }
        defaults.set(decisionsRaw, forKey: "preferences.enabledDecisions")
        defaults.set(temperatureUnit.rawValue, forKey: "preferences.temperatureUnit")
        defaults.set(notificationsEnabled, forKey: "preferences.notificationsEnabled")
        defaults.set(region?.rawValue ?? "", forKey: "preferences.region")
        defaults.set(hasCompletedOnboarding, forKey: "preferences.hasCompletedOnboarding")
        if let notificationTime {
            defaults.set(notificationTime.timeIntervalSince1970, forKey: "preferences.notificationTime")
        } else {
            defaults.removeObject(forKey: "preferences.notificationTime")
        }
    }

    func load() {
        if let raw = defaults.stringArray(forKey: "preferences.enabledDecisions") {
            enabledDecisions = Set(raw.compactMap { DecisionType(rawValue: $0) })
            if enabledDecisions.isEmpty { enabledDecisions = [.temperature] }
        }
        if let unitRaw = defaults.string(forKey: "preferences.temperatureUnit"),
           let unit = TemperatureUnit(rawValue: unitRaw) {
            temperatureUnit = unit
        }
        notificationsEnabled = defaults.bool(forKey: "preferences.notificationsEnabled")
        hasCompletedOnboarding = defaults.bool(forKey: "preferences.hasCompletedOnboarding")
        if let regionRaw = defaults.string(forKey: "preferences.region"), !regionRaw.isEmpty {
            region = RegionProfile(rawValue: regionRaw)
        }
        let timeInterval = defaults.double(forKey: "preferences.notificationTime")
        notificationTime = timeInterval > 0 ? Date(timeIntervalSince1970: timeInterval) : nil
    }

    func reset() {
        enabledDecisions = [.temperature]
        temperatureUnit = .fahrenheit
        notificationTime = nil
        notificationsEnabled = false
        region = nil
        save()
    }
}
