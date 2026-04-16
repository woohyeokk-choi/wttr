import SwiftUI
import SharedKit

struct StatsDetailView: View {
    let category: StatCategory
    @Environment(WeatherStore.self) private var weatherStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerCard
                chartCard
            }
            .padding(16)
        }
        .navigationTitle(category.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var headerCard: some View {
        HStack(spacing: 16) {
            Image(systemName: category.iconName)
                .font(.system(size: 36))
                .foregroundStyle(.tint)
            VStack(alignment: .leading, spacing: 4) {
                Text(currentValueLabel)
                    .font(.system(size: 36, weight: .bold))
                Text(category.displayName)
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color("Surface"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Next 24 Hours")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)

            if hourlyDataPoints.isEmpty {
                Text("No data available")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 160)
            } else {
                SimpleBarChart(dataPoints: hourlyDataPoints)
                    .frame(height: 160)
            }
        }
        .padding(20)
        .background(Color("Surface"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var currentValueLabel: String {
        guard let weather = weatherStore.currentWeather else { return "--" }
        switch category {
        case .precipitation:
            return weatherStore.hourlyForecast.first.map {
                String(format: "%.0f%%", $0.precipitationChance * 100)
            } ?? "--"
        case .wind:
            return String(format: "%.0f km/h", weather.windSpeed)
        case .humidity:
            return String(format: "%.0f%%", weather.humidity * 100)
        case .uvIndex:
            return "\(weather.uvIndex)"
        case .cloudCover:
            return String(format: "%.0f%%", weather.cloudCover * 100)
        case .visibility:
            return "--"
        case .pressure:
            return "--"
        case .airQuality:
            return weatherStore.airQuality.map { "\($0.aqi) AQI" } ?? "--"
        case .daylight:
            if let today = weatherStore.dailyForecast.first {
                let hours = today.sunset.timeIntervalSince(today.sunrise) / 3600
                return String(format: "%.1fh", hours)
            }
            return "--"
        }
    }

    private var hourlyDataPoints: [BarDataPoint] {
        let hourly = weatherStore.hourlyForecast
        guard !hourly.isEmpty else { return [] }

        let formatter = DateFormatter()
        formatter.dateFormat = "ha"

        return hourly.prefix(24).map { forecast in
            let value: Double
            switch category {
            case .precipitation:
                value = forecast.precipitationChance * 100
            case .wind:
                value = forecast.condition.windSpeed
            case .humidity:
                value = forecast.condition.humidity * 100
            case .uvIndex:
                value = Double(forecast.condition.uvIndex)
            case .cloudCover:
                value = forecast.condition.cloudCover * 100
            case .visibility:
                value = 0
            case .pressure:
                value = 0
            case .airQuality:
                value = Double(weatherStore.airQuality?.aqi ?? 0)
            case .daylight:
                value = 0
            }
            return BarDataPoint(label: formatter.string(from: forecast.hour), value: value)
        }
    }
}

struct BarDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
}

struct SimpleBarChart: View {
    let dataPoints: [BarDataPoint]

    private var maxValue: Double {
        dataPoints.map(\.value).max() ?? 1
    }

    var body: some View {
        GeometryReader { geo in
            HStack(alignment: .bottom, spacing: 3) {
                ForEach(Array(dataPoints.enumerated()), id: \.offset) { index, point in
                    let barHeight = maxValue > 0
                        ? max(4, (point.value / maxValue) * (geo.size.height - 24))
                        : 4
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.accentColor.opacity(0.75))
                            .frame(height: barHeight)
                        if index % 6 == 0 {
                            Text(point.label)
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .fixedSize()
                        } else {
                            Color.clear.frame(height: 14)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}
