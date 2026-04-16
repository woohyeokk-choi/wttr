import Foundation

public struct UserPreferences: Codable, Sendable {
    public var enabledDecisions: Set<DecisionType>
    public var temperatureUnit: TemperatureUnit
    public var notificationTime: Date?
    public var notificationsEnabled: Bool
    public var region: RegionProfile?

    public static var `default`: UserPreferences {
        UserPreferences(
            enabledDecisions: [.temperature],
            temperatureUnit: .fahrenheit,
            notificationTime: nil,
            notificationsEnabled: false,
            region: nil
        )
    }

    public init(
        enabledDecisions: Set<DecisionType>,
        temperatureUnit: TemperatureUnit,
        notificationTime: Date?,
        notificationsEnabled: Bool,
        region: RegionProfile?
    ) {
        self.enabledDecisions = enabledDecisions
        self.temperatureUnit = temperatureUnit
        self.notificationTime = notificationTime
        self.notificationsEnabled = notificationsEnabled
        self.region = region
    }
}
