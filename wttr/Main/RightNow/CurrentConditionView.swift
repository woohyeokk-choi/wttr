import SwiftUI
import SharedKit

struct CurrentConditionView: View {
    let condition: WeatherCondition
    let yesterday: YesterdayComparison?
    let temperatureUnit: TemperatureUnit

    private var tempDiff: Double? {
        guard let yesterday else { return nil }
        return condition.temperature - yesterday.high
    }

    private var formattedTemp: String {
        let temp = temperatureUnit.convert(fromCelsius: condition.temperature)
        return "\(Int(temp.rounded()))°"
    }

    private var formattedFeelsLike: String {
        let temp = temperatureUnit.convert(fromCelsius: condition.feelsLike)
        return "Feels \(Int(temp.rounded()))°"
    }

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 12) {
                Image(systemName: condition.icon)
                    .font(.system(size: 48))
                    .symbolRenderingMode(.multicolor)
                Text(formattedTemp)
                    .font(.system(size: 64, weight: .bold))
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            }
            Text(formattedFeelsLike)
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
            if let diff = tempDiff {
                let absDiff = Int(abs(diff).rounded())
                let text = diff > 2 ? "\(absDiff)° warmer" : diff < -2 ? "\(absDiff)° colder" : "Similar to yesterday"
                let color: Color = diff > 2 ? Color("Warning") : diff < -2 ? Color("Info") : .secondary
                Text(text)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(color)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}
