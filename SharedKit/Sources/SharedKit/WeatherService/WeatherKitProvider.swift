#if canImport(WeatherKit)
import Foundation
import WeatherKit
import CoreLocation

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
final class WeatherKitProvider: WeatherProvider, @unchecked Sendable {
    static let maxHours: Int = 48
    static let maxDays: Int = 10

    private let service = WeatherService.shared

    // MARK: - WeatherProvider

    func currentWeather(for location: LocationData) async throws -> WeatherCondition {
        do {
            let current = try await service.weather(for: makeCLLocation(location), including: .current)
            let conditionType = mapConditionType(current.condition, isDaylight: current.isDaylight)
            return WeatherCondition(
                temperature: current.temperature.value,
                feelsLike: current.apparentTemperature.value,
                humidity: current.humidity,
                windSpeed: current.wind.speed.value,
                windDirection: current.wind.direction.value,
                cloudCover: current.cloudCover,
                uvIndex: current.uvIndex.value,
                condition: conditionType,
                icon: conditionType.sfSymbolName,
                date: current.date
            )
        } catch {
            throw mapError(error)
        }
    }

    func hourlyForecast(for location: LocationData, hours: Int) async throws -> [HourlyForecast] {
        do {
            let forecast = try await service.weather(for: makeCLLocation(location), including: .hourly)
            return forecast.forecast
                .prefix(min(hours, Self.maxHours))
                .map { hour in
                    let conditionType = mapConditionType(hour.condition, isDaylight: hour.isDaylight)
                    let condition = WeatherCondition(
                        temperature: hour.temperature.value,
                        feelsLike: hour.apparentTemperature.value,
                        humidity: hour.humidity,
                        windSpeed: hour.wind.speed.value,
                        windDirection: hour.wind.direction.value,
                        cloudCover: hour.cloudCover,
                        uvIndex: hour.uvIndex.value,
                        condition: conditionType,
                        icon: conditionType.sfSymbolName,
                        date: hour.date
                    )
                    return HourlyForecast(
                        hour: hour.date,
                        condition: condition,
                        precipitationChance: hour.precipitationChance,
                        precipitationType: mapPrecipitationType(hour.precipitation),
                        precipitationAmount: hour.precipitationAmount.value
                    )
                }
        } catch {
            throw mapError(error)
        }
    }

    func dailyForecast(for location: LocationData, days: Int) async throws -> [DailyForecast] {
        do {
            let forecast = try await service.weather(for: makeCLLocation(location), including: .daily)
            let calendar = Calendar.current
            return forecast.forecast
                .prefix(min(days, Self.maxDays))
                .map { day in
                    let conditionType = mapConditionType(day.condition, isDaylight: true)
                    let condition = WeatherCondition(
                        temperature: day.highTemperature.value,
                        feelsLike: day.highTemperature.value,
                        humidity: 0,
                        windSpeed: day.wind.speed.value,
                        windDirection: day.wind.direction.value,
                        cloudCover: 0,
                        uvIndex: day.uvIndex.value,
                        condition: conditionType,
                        icon: conditionType.sfSymbolName,
                        date: day.date
                    )
                    let noon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: day.date) ?? day.date
                    let evening = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: day.date) ?? day.date
                    return DailyForecast(
                        date: day.date,
                        high: day.highTemperature.value,
                        low: day.lowTemperature.value,
                        condition: condition,
                        precipChance: day.precipitationChance,
                        sunrise: day.sun.sunrise ?? noon,
                        sunset: day.sun.sunset ?? evening,
                        moonPhase: mapMoonPhase(day.moon.phase)
                    )
                }
        } catch {
            throw mapError(error)
        }
    }

    func yesterdayComparison(for location: LocationData) async throws -> YesterdayComparison {
        do {
            let tz = TimeZone(identifier: location.timeZone) ?? .current
            var calendar = Calendar.current
            calendar.timeZone = tz
            let today = Date()
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                  let startOfYesterday = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: yesterday),
                  let endOfYesterday = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: yesterday)
            else {
                throw WeatherProviderError.unknown(description: "Failed to compute yesterday date range")
            }
            let forecast = try await service.weather(
                for: makeCLLocation(location),
                including: .daily(startDate: startOfYesterday, endDate: endOfYesterday)
            )
            let day = forecast.forecast.first
            return YesterdayComparison(
                high: day?.highTemperature.value ?? 0,
                low: day?.lowTemperature.value ?? 0,
                fetchedAt: Date()
            )
        } catch let error as WeatherProviderError {
            throw error
        } catch {
            throw mapError(error)
        }
    }

    func airQuality(for location: LocationData) async throws -> AirQualityData {
        // TODO: Implement real AQI when WeatherKit AQ API is confirmed available
        return AirQualityData(aqi: 30, category: .good, primaryPollutant: "PM2.5", pm25: 10, pm10: 15)
    }

    // MARK: - Mapping helpers

    private func mapConditionType(_ wkCondition: WeatherKit.WeatherCondition, isDaylight: Bool) -> WeatherConditionType {
        switch wkCondition {
        case .clear, .hot:
            return isDaylight ? .clear : .clearNight
        case .mostlyClear:
            return isDaylight ? .clear : .clearNight
        case .partlyCloudy, .sunShowers:
            return isDaylight ? .partlyCloudy : .partlyCloudyNight
        case .mostlyCloudy:
            return isDaylight ? .partlyCloudy : .partlyCloudyNight
        case .cloudy:
            return isDaylight ? .cloudy : .cloudyNight
        case .drizzle, .freezingDrizzle:
            return .drizzle
        case .rain:
            return .rain
        case .heavyRain:
            return .heavyRain
        case .isolatedThunderstorms, .scatteredThunderstorms, .thunderstorms, .strongStorms, .tropicalStorm, .hurricane:
            return .thunderstorm
        case .snow, .flurries, .sunFlurries:
            return .snow
        case .heavySnow, .blizzard:
            return .blizzard
        case .sleet, .freezingRain, .wintryMix:
            return .sleet
        case .hail:
            return .rain
        case .foggy:
            return .fog
        case .haze, .smoky:
            return .haze
        case .blowingDust, .blowingSnow, .breezy, .windy:
            return .windy
        case .frigid:
            return .cloudy
        @unknown default:
            return .cloudy
        }
    }

    private func mapPrecipitationType(_ precipitation: WeatherKit.Precipitation) -> PrecipitationType {
        switch precipitation {
        case .none:
            return .none
        case .rain:
            return .rain
        case .snow:
            return .snow
        case .sleet:
            return .sleet
        case .hail:
            return .hail
        case .mixed:
            return .sleet
        @unknown default:
            return .none
        }
    }

    private func mapMoonPhase(_ phase: WeatherKit.MoonPhase) -> SharedKit.MoonPhase {
        switch phase {
        case .new:
            return .new
        case .waxingCrescent:
            return .waxingCrescent
        case .firstQuarter:
            return .firstQuarter
        case .waxingGibbous:
            return .waxingGibbous
        case .full:
            return .full
        case .waningGibbous:
            return .waningGibbous
        case .lastQuarter:
            return .lastQuarter
        case .waningCrescent:
            return .waningCrescent
        @unknown default:
            return .new
        }
    }

    private func mapError(_ error: Error) -> WeatherProviderError {
        if let weatherError = error as? WeatherError {
            switch weatherError {
            case .permissionDenied:
                return .notEntitled
            default:
                return .unknown(description: weatherError.localizedDescription)
            }
        }
        if let urlError = error as? URLError {
            if urlError.code.rawValue == 429 {
                return .rateLimited
            }
            return .networkError(urlError)
        }
        return .unknown(description: error.localizedDescription)
    }

    private func makeCLLocation(_ location: LocationData) -> CLLocation {
        CLLocation(latitude: location.latitude, longitude: location.longitude)
    }
}
#endif
