import Foundation
import CoreLocation
@testable import SharedKit

public final class MockLocationProvider: LocationProvider, @unchecked Sendable {
    public var errorToThrow: LocationProviderError?
    public var simulatedDelay: TimeInterval = 0
    public var stubbedLocation: LocationData
    public var stubbedSavedLocations: [LocationData]
    public var requestLocationCallCount = 0
    public var currentLocation: LocationData?

    public var locationUpdates: AsyncStream<LocationData> {
        AsyncStream { _ in }
    }

    public var stubbedAuthorizationStatus: CLAuthorizationStatus = {
        #if os(macOS)
        return .authorizedAlways
        #else
        return .authorizedWhenInUse
        #endif
    }()

    public var authorizationStatus: CLAuthorizationStatus { stubbedAuthorizationStatus }

    public var authorizationUpdates: AsyncStream<CLAuthorizationStatus> {
        AsyncStream { [stubbedAuthorizationStatus] continuation in
            continuation.yield(stubbedAuthorizationStatus)
            continuation.finish()
        }
    }

    public init(location: LocationData = .previewSanFrancisco) {
        self.stubbedLocation = location
        self.stubbedSavedLocations = [location]
        self.currentLocation = location
    }

    public func requestPermission() async -> CLAuthorizationStatus {
        #if os(macOS)
        .authorizedAlways
        #else
        .authorizedWhenInUse
        #endif
    }

    public func currentLocation() async throws -> LocationData {
        requestLocationCallCount += 1
        if let error = errorToThrow { throw error }
        if simulatedDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(simulatedDelay * 1_000_000_000))
        }
        return stubbedLocation
    }

    public func startMonitoring() {}
    public func stopMonitoring() {}
}
