import Foundation
import CoreLocation
import SharedKit

// Placeholder providers used until WeatherKit entitlement is provisioned.
// Replace with real providers once production keys are configured.
final class PreviewWeatherProvider: WeatherProvider, @unchecked Sendable {
    private let now = Date()

    func currentWeather(for location: LocationData) async throws -> WeatherCondition {
        WeatherCondition(
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
    }

    func hourlyForecast(for location: LocationData, hours: Int) async throws -> [HourlyForecast] {
        (0..<hours).map { i in
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
    }

    func dailyForecast(for location: LocationData, days: Int) async throws -> [DailyForecast] {
        (0..<days).map { i in
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
    }

    func yesterdayComparison(for location: LocationData) async throws -> YesterdayComparison {
        YesterdayComparison(high: 21.0, low: 12.5, fetchedAt: now)
    }

    func airQuality(for location: LocationData) async throws -> AirQualityData {
        AirQualityData(aqi: 29, category: .good, primaryPollutant: "PM2.5", pm25: 12.0, pm10: 18.0)
    }
}

final class PreviewLocationProvider: LocationProvider, @unchecked Sendable {
    var locationUpdates: AsyncStream<LocationData> {
        AsyncStream { _ in }
    }

    var authorizationStatus: CLAuthorizationStatus { .authorizedWhenInUse }

    var authorizationUpdates: AsyncStream<CLAuthorizationStatus> {
        AsyncStream { continuation in
            continuation.yield(.authorizedWhenInUse)
            continuation.finish()
        }
    }

    func requestPermission() async -> CLAuthorizationStatus {
        .authorizedWhenInUse
    }

    func currentLocation() async throws -> LocationData {
        .previewSanFrancisco
    }

    func startMonitoring() {}
    func stopMonitoring() {}
}
