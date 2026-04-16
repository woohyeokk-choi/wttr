import Foundation
import CoreLocation

public enum LocationProviderError: Error, Sendable {
    case permissionDenied
    case locationServicesDisabled
    case locationTimeout
    case geocodingFailed
    case unknown(CLError)
}
