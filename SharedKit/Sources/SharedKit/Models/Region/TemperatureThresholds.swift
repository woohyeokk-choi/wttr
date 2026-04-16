public struct TemperatureThresholds: Codable, Sendable {
    public var freezing: Double
    public var cold: Double
    public var cool: Double
    public var mild: Double

    public init(
        freezing: Double,
        cold: Double,
        cool: Double,
        mild: Double
    ) {
        self.freezing = freezing
        self.cold = cold
        self.cool = cool
        self.mild = mild
    }
}
