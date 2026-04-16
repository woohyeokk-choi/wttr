import SwiftUI
import SharedKit

enum StatCategory: String, CaseIterable, Hashable {
    case precipitation
    case wind
    case humidity
    case uvIndex
    case cloudCover
    case visibility
    case pressure
    case airQuality
    case daylight

    var displayName: String {
        switch self {
        case .precipitation: return "Precipitation"
        case .wind: return "Wind"
        case .humidity: return "Humidity"
        case .uvIndex: return "UV Index"
        case .cloudCover: return "Cloud Cover"
        case .visibility: return "Visibility"
        case .pressure: return "Pressure"
        case .airQuality: return "Air Quality"
        case .daylight: return "Daylight"
        }
    }

    var iconName: String {
        switch self {
        case .precipitation: return "cloud.rain.fill"
        case .wind: return "wind"
        case .humidity: return "humidity.fill"
        case .uvIndex: return "sun.max.fill"
        case .cloudCover: return "cloud.fill"
        case .visibility: return "eye.fill"
        case .pressure: return "gauge.medium"
        case .airQuality: return "aqi.medium"
        case .daylight: return "sunrise.fill"
        }
    }
}

struct StatsView: View {
    @Environment(WeatherStore.self) private var weatherStore

    var body: some View {
        NavigationStack {
            Group {
                if weatherStore.isLoading && weatherStore.currentWeather == nil {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(0..<9, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color("Surface"))
                                .frame(height: 100)
                        }
                    }
                    .padding(16)
                } else if weatherStore.currentWeather != nil {
                    StatsGridView()
                } else {
                    ContentUnavailableView(
                        "No Stats",
                        systemImage: "chart.bar",
                        description: Text("Weather data needed")
                    )
                }
            }
            .navigationTitle("Stats")
            .navigationDestination(for: StatCategory.self) { category in
                StatsDetailView(category: category)
            }
        }
    }
}
