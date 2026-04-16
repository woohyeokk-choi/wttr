import Foundation
import SharedKit

enum EventAlertType: String, CaseIterable, Sendable {
    case rainStarting
    case uvSpike
    case aqiCrossing
}

struct EventAlertDetector: Sendable {
    static let rainThresholdLow: Double = 0.20
    static let rainThresholdHigh: Double = 0.40
    static let uvSpikeMinDelta: Int = 2
    static let alertCooldown: TimeInterval = 3 * 3600  // 3 hours

    func detect(
        cachedHourly: [HourlyForecast],
        freshHourly: [HourlyForecast],
        cachedAQI: AirQualityData?,
        freshAQI: AirQualityData?,
        lastAlertTimes: [String: TimeInterval]
    ) -> [EventAlertType] {
        var alerts: [EventAlertType] = []
        let now = Date().timeIntervalSince1970

        // Rain starting
        if !isOnCooldown(.rainStarting, lastAlertTimes: lastAlertTimes, now: now) {
            let cachedMax = cachedHourly.prefix(2).map(\.precipitationChance).max() ?? 0
            let freshMax = freshHourly.prefix(2).map(\.precipitationChance).max() ?? 0
            if cachedMax < Self.rainThresholdLow && freshMax > Self.rainThresholdHigh {
                alerts.append(.rainStarting)
            }
        }

        // UV spike
        if !isOnCooldown(.uvSpike, lastAlertTimes: lastAlertTimes, now: now) {
            for i in 0..<min(6, min(cachedHourly.count, freshHourly.count)) {
                let delta = freshHourly[i].condition.uvIndex - cachedHourly[i].condition.uvIndex
                if delta >= Self.uvSpikeMinDelta {
                    alerts.append(.uvSpike)
                    break
                }
            }
        }

        // AQI crossing
        if !isOnCooldown(.aqiCrossing, lastAlertTimes: lastAlertTimes, now: now),
           let cached = cachedAQI, let fresh = freshAQI {
            let cachedRank = categoryRank(cached.category)
            let freshRank = categoryRank(fresh.category)
            if freshRank > cachedRank {
                alerts.append(.aqiCrossing)
            }
        }

        return alerts
    }

    private func isOnCooldown(_ type: EventAlertType, lastAlertTimes: [String: TimeInterval], now: TimeInterval) -> Bool {
        guard let lastTime = lastAlertTimes[type.rawValue] else { return false }
        return (now - lastTime) < Self.alertCooldown
    }

    private func categoryRank(_ category: AirQualityCategory) -> Int {
        switch category {
        case .good: return 0
        case .moderate: return 1
        case .unhealthySensitive: return 2
        case .unhealthy: return 3
        case .veryUnhealthy: return 4
        case .hazardous: return 5
        }
    }
}
