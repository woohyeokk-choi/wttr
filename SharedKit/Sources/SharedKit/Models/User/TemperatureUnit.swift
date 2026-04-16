import Foundation

public enum TemperatureUnit: String, Codable, Sendable, CaseIterable {
    case celsius = "celsius"
    case fahrenheit = "fahrenheit"

    /// The display symbol for this unit, e.g. "°C" or "°F"
    public var symbol: String {
        switch self {
        case .celsius: return "°C"
        case .fahrenheit: return "°F"
        }
    }

    /// Convert a Celsius value to this unit
    public func convert(fromCelsius celsius: Double) -> Double {
        switch self {
        case .celsius: return celsius
        case .fahrenheit: return celsius * 9.0 / 5.0 + 32.0
        }
    }
}
