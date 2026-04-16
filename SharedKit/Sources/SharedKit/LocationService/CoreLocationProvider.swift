import Foundation
import CoreLocation

@available(iOS 15, macOS 12, *)
public final class CoreLocationProvider: NSObject, LocationProvider, CLLocationManagerDelegate, @unchecked Sendable {
    private let manager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<LocationData, Error>?
    private var permissionContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?
    private var streamContinuation: AsyncStream<LocationData>.Continuation?
    private var authContinuation: AsyncStream<CLAuthorizationStatus>.Continuation?

    public private(set) var currentLocation: LocationData?

    public var locationUpdates: AsyncStream<LocationData> {
        AsyncStream { [weak self] continuation in
            self?.streamContinuation = continuation
        }
    }

    public var authorizationStatus: CLAuthorizationStatus {
        manager.authorizationStatus
    }

    public var authorizationUpdates: AsyncStream<CLAuthorizationStatus> {
        AsyncStream { [weak self] continuation in
            self?.authContinuation = continuation
            // Seed the stream with the current value so consumers don't wait
            // for the first delegate callback before rendering initial UI.
            if let self {
                continuation.yield(self.manager.authorizationStatus)
            }
        }
    }

    public override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.distanceFilter = 5000 // 5 km
    }

    public func requestPermission() async -> CLAuthorizationStatus {
        let status = manager.authorizationStatus
        guard status == .notDetermined else { return status }
        return await withCheckedContinuation { continuation in
            self.permissionContinuation = continuation
            manager.requestWhenInUseAuthorization()
        }
    }

    public func currentLocation() async throws -> LocationData {
        try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            manager.requestLocation()
        }
    }

    public func startMonitoring() {
        manager.startMonitoringSignificantLocationChanges()
    }

    public func stopMonitoring() {
        manager.stopMonitoringSignificantLocationChanges()
    }

    // MARK: - CLLocationManagerDelegate

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let clLocation = locations.last else { return }
        Task {
            let locationData = await self.resolveLocation(clLocation)
            self.currentLocation = locationData
            self.locationContinuation?.resume(returning: locationData)
            self.locationContinuation = nil
            self.streamContinuation?.yield(locationData)
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let providerError: LocationProviderError
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                providerError = .permissionDenied
            case .locationUnknown:
                providerError = .locationTimeout
            default:
                providerError = .unknown(clError)
            }
        } else {
            providerError = .locationTimeout
        }
        locationContinuation?.resume(throwing: providerError)
        locationContinuation = nil
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        // Always broadcast the latest status so UI (badges, banners) can react
        // even when the user changes permission from Settings while the app runs.
        authContinuation?.yield(status)

        // Delegate fires once with .notDetermined right after delegate assignment
        // and again with .notDetermined immediately after requestWhenInUseAuthorization().
        // We must only resume the awaiting caller once the user has actually made a
        // choice; otherwise the caller advances before the system prompt appears.
        guard status != .notDetermined else { return }
        permissionContinuation?.resume(returning: status)
        permissionContinuation = nil
    }

    // MARK: - Reverse geocoding

    private func resolveLocation(_ clLocation: CLLocation) async -> LocationData {
        let geocoder = CLGeocoder()
        let placemarks = try? await geocoder.reverseGeocodeLocation(clLocation)
        let placemark = placemarks?.first
        return LocationData(
            latitude: clLocation.coordinate.latitude,
            longitude: clLocation.coordinate.longitude,
            city: placemark?.locality ?? "Unknown",
            state: placemark?.administrativeArea ?? "",
            country: placemark?.isoCountryCode ?? "",
            timeZone: placemark?.timeZone?.identifier ?? TimeZone.current.identifier
        )
    }
}
