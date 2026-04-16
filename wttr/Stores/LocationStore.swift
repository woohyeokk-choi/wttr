import SwiftUI
import SharedKit
import CoreLocation

@Observable
final class LocationStore: @unchecked Sendable {
    var currentLocation: LocationData?
    var savedLocations: [LocationData] = []
    var selectedLocationIndex: Int = 0
    var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private let locationProvider: any LocationProvider
    private var authObservationTask: Task<Void, Never>?

    /// True when the system has explicitly denied or restricted location access,
    /// or when the user picked "Allow Once" and the authorization has since
    /// expired. UI surfaces (header badge, empty state, widget placeholder)
    /// read this to show the red `location.slash` indicator.
    var isLocationBlocked: Bool {
        switch authorizationStatus {
        case .denied, .restricted:
            return true
        case .notDetermined, .authorizedWhenInUse, .authorizedAlways:
            return false
        @unknown default:
            return false
        }
    }

    init(locationProvider: any LocationProvider) {
        self.locationProvider = locationProvider
        self.authorizationStatus = locationProvider.authorizationStatus
        startObservingAuthorization()
    }

    deinit {
        authObservationTask?.cancel()
    }

    private func startObservingAuthorization() {
        let stream = locationProvider.authorizationUpdates
        authObservationTask = Task { @MainActor [weak self] in
            for await status in stream {
                self?.authorizationStatus = status
                self?.persistAuthorizationState(status)
            }
        }
    }

    private func persistAuthorizationState(_ status: CLAuthorizationStatus) {
        // Widgets read this flag from the shared App Group container to show
        // the same red `location.slash` badge on the home screen.
        let blocked: Bool
        switch status {
        case .denied, .restricted: blocked = true
        default: blocked = false
        }
        UserDefaults(suiteName: "group.com.wttr.app")?
            .set(blocked, forKey: "location.isBlocked")
    }

    var selectedLocation: LocationData? {
        guard !savedLocations.isEmpty, selectedLocationIndex < savedLocations.count else {
            return currentLocation
        }
        return savedLocations[selectedLocationIndex]
    }

    func requestPermission() async {
        authorizationStatus = await locationProvider.requestPermission()
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            do {
                let location = try await locationProvider.currentLocation()
                self.currentLocation = location
                if savedLocations.isEmpty {
                    savedLocations = [location]
                } else {
                    savedLocations[0] = location
                }
            } catch {
                // location will remain nil
            }
        }
    }

    func startMonitoring() { locationProvider.startMonitoring() }
    func stopMonitoring() { locationProvider.stopMonitoring() }

    func addLocation(_ location: LocationData) {
        savedLocations.append(location)
    }

    func removeLocation(at index: Int) {
        guard index > 0, index < savedLocations.count else { return }
        savedLocations.remove(at: index)
        if selectedLocationIndex >= savedLocations.count {
            selectedLocationIndex = max(0, savedLocations.count - 1)
        }
    }

    func selectLocation(at index: Int) {
        guard index >= 0, index < savedLocations.count else { return }
        selectedLocationIndex = index
    }
}
