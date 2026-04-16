import Foundation

/// Protocol for feature-availability checks.
public protocol FeatureGate: AnyObject, Sendable {
    func isAvailable(_ feature: Feature) -> Bool
    func requiresPro(for feature: Feature) -> Bool
}

/// Default implementation using a closure for isProUser check (no StoreKit import).
public final class DefaultFeatureGate: FeatureGate, @unchecked Sendable {
    private let isProUserProvider: @Sendable () -> Bool

    public init(isProUserProvider: @escaping @Sendable () -> Bool) {
        self.isProUserProvider = isProUserProvider
    }

    public func isAvailable(_ feature: Feature) -> Bool {
        switch feature {
        case .allWidgets, .eventAlerts, .multipleLocations, .themes:
            return isProUserProvider()
        case .fullCharacter, .allStyles, .outfitPacks:
            return false // Weather Me only
        case .watch, .multipleSources:
            return false // v2
        }
    }

    public func requiresPro(for feature: Feature) -> Bool {
        switch feature {
        case .allWidgets, .eventAlerts, .multipleLocations, .themes:
            return true
        case .fullCharacter, .allStyles, .outfitPacks:
            return true
        case .watch, .multipleSources:
            return false // v2 — not gated yet
        }
    }
}
