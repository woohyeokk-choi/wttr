import Foundation

extension Double {
    /// Celsius to Fahrenheit
    public func celsiusToFahrenheit() -> Double {
        self * 9.0 / 5.0 + 32.0
    }

    /// Fahrenheit to Celsius
    public func fahrenheitToCelsius() -> Double {
        (self - 32.0) * 5.0 / 9.0
    }

    /// Format temp with unit symbol and one decimal, e.g. "23.1°C"
    public func formattedTemperature(unit: TemperatureUnit) -> String {
        let converted = unit.convert(fromCelsius: self)
        return String(format: "%.1f%@", converted, unit.symbol)
    }
}
