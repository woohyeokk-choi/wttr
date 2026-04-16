import SwiftUI
import SharedKit

private struct FeatureGateKey: EnvironmentKey {
    static let defaultValue: any FeatureGate = DefaultFeatureGate(isProUserProvider: { false })
}

extension EnvironmentValues {
    var featureGate: any FeatureGate {
        get { self[FeatureGateKey.self] }
        set { self[FeatureGateKey.self] = newValue }
    }
}
