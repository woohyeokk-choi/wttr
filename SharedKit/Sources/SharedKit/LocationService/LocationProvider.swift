import Foundation
import CoreLocation

@available(iOS 15, macOS 12, *)
public protocol LocationProvider: AnyObject, Sendable {
    func requestPermission() async -> CLAuthorizationStatus
    func currentLocation() async throws -> LocationData
    func startMonitoring()
    func stopMonitoring()
    var locationUpdates: AsyncStream<LocationData> { get }

    /// Current authorization status, safe to read synchronously from the main actor.
    /// Used to gate UI state (e.g., the "location blocked" badge).
    var authorizationStatus: CLAuthorizationStatus { get }

    /// Emits each time the system authorization status changes (user toggles
    /// permission in Settings, grants/revokes at runtime, etc.).
    var authorizationUpdates: AsyncStream<CLAuthorizationStatus> { get }
}
