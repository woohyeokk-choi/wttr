import Foundation

public protocol AirQualityProvider: AnyObject, Sendable {
    func airQuality(for location: LocationData) async throws -> AirQualityData
}
