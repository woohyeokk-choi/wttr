import SwiftUI
import SharedKit

struct HourlyBarChartView: View {
    let hourlyForecast: [HourlyForecast]
    let temperatureUnit: TemperatureUnit
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var tempRange: ClosedRange<Double> {
        let temps = hourlyForecast.map(\.condition.temperature)
        let minT = (temps.min() ?? 0) - 2
        let maxT = (temps.max() ?? 30) + 2
        return minT...maxT
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(hourlyForecast.prefix(24).enumerated()), id: \.offset) { _, hour in
                    VStack(spacing: 4) {
                        let temp = temperatureUnit.convert(fromCelsius: hour.condition.temperature)
                        Text("\(Int(temp.rounded()))°")
                            .font(.system(size: 13, weight: .semibold))
                            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)

                        let height = barHeight(for: hour.condition.temperature)
                        RoundedRectangle(cornerRadius: 8)
                            .fill(temperatureColor(for: hour.condition.temperature))
                            .frame(width: 40, height: height)

                        Text(hour.hour.shortTimeString(in: .current))
                            .font(.system(size: 13, weight: .medium))
                            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)

                        Image(systemName: hour.condition.condition.sfSymbolName)
                            .font(.system(size: 14))
                            .symbolRenderingMode(.multicolor)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(hour.hour.shortTimeString(in: .current)) \(Int(temperatureUnit.convert(fromCelsius: hour.condition.temperature).rounded()))°, \(Int(hour.precipitationChance * 100))% chance of \(hour.precipitationType.rawValue)")
                }
            }
            .padding(.horizontal, 16)
        }
        .accessibilityLabel("Hourly forecast")
    }

    private func barHeight(for temp: Double) -> CGFloat {
        let range = tempRange.upperBound - tempRange.lowerBound
        guard range > 0 else { return 40 }
        let normalized = (temp - tempRange.lowerBound) / range
        return CGFloat(40 + normalized * 80)
    }

    private func temperatureColor(for tempCelsius: Double) -> Color {
        switch tempCelsius {
        case ..<0: return Color(red: 0.35, green: 0.78, blue: 0.98)    // Ice Blue
        case 0..<10: return Color(red: 0.20, green: 0.78, blue: 0.35)  // Green
        case 10..<18: return Color(red: 0.19, green: 0.82, blue: 0.35) // Light Green
        case 18..<24: return Color(red: 1.0, green: 0.84, blue: 0.04)  // Yellow
        case 24..<30: return Color(red: 1.0, green: 0.62, blue: 0.04)  // Orange
        default: return Color(red: 1.0, green: 0.27, blue: 0.23)       // Red
        }
    }
}
