import SwiftUI
import SharedKit

struct WeeklyForecastList: View {
    let dailyForecast: [DailyForecast]
    let temperatureUnit: TemperatureUnit

    private var weekTempRange: ClosedRange<Double> {
        let lows = dailyForecast.map(\.low)
        let highs = dailyForecast.map(\.high)
        return (lows.min() ?? 0)...(highs.max() ?? 30)
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(dailyForecast.enumerated()), id: \.offset) { index, forecast in
                if index > 0 { Divider() }
                DailyForecastRow(forecast: forecast, temperatureUnit: temperatureUnit, weekTempRange: weekTempRange)
            }
        }
    }
}

struct DailyForecastRow: View {
    let forecast: DailyForecast
    let temperatureUnit: TemperatureUnit
    let weekTempRange: ClosedRange<Double>
    @Environment(\.colorSchemeContrast) private var contrast

    private var dayName: String {
        forecast.date.weekdayName(abbreviated: true).uppercased()
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(dayName)
                .font(.system(size: 15, weight: .medium))
                .frame(width: 40, alignment: .leading)

            Image(systemName: forecast.condition.condition.sfSymbolName)
                .font(.system(size: 20))
                .symbolRenderingMode(.multicolor)
                .frame(width: 28)

            if forecast.precipChance > 0 {
                Text("\(Int(forecast.precipChance * 100))%")
                    .font(.system(size: 13))
                    .foregroundStyle(Color(red: 0.345, green: 0.337, blue: 0.839))
                    .frame(width: 36)
            } else {
                Spacer().frame(width: 36)
            }

            let lowTemp = Int(temperatureUnit.convert(fromCelsius: forecast.low).rounded())
            Text("\(lowTemp)°")
                .font(.system(size: 15))
                .frame(width: 36, alignment: .trailing)

            GeometryReader { geo in
                let range = weekTempRange.upperBound - weekTempRange.lowerBound
                let start = range > 0 ? (forecast.low - weekTempRange.lowerBound) / range : 0
                let end = range > 0 ? (forecast.high - weekTempRange.lowerBound) / range : 1

                RoundedRectangle(cornerRadius: 4)
                    .fill(LinearGradient(colors: [Color("Info"), Color("Warning")], startPoint: .leading, endPoint: .trailing))
                    .frame(width: geo.size.width * CGFloat(end - start), height: 8)
                    .offset(x: geo.size.width * CGFloat(start))
                    .overlay {
                        if contrast == .increased {
                            RoundedRectangle(cornerRadius: 4).stroke(Color.primary.opacity(0.3), lineWidth: 1)
                        }
                    }
                    .frame(height: geo.size.height, alignment: .center)
            }
            .frame(height: 8)

            let highTemp = Int(temperatureUnit.convert(fromCelsius: forecast.high).rounded())
            Text("\(highTemp)°")
                .font(.system(size: 15))
                .frame(width: 36, alignment: .leading)
        }
        .frame(height: 44)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(dayName), High \(Int(temperatureUnit.convert(fromCelsius: forecast.high).rounded()))°, Low \(Int(temperatureUnit.convert(fromCelsius: forecast.low).rounded()))°, \(forecast.condition.condition.displayName)\(forecast.precipChance > 0 ? ", \(Int(forecast.precipChance * 100))% chance of rain" : "")")
    }
}
