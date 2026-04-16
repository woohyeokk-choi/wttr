import SwiftUI
import SharedKit

struct UnitsView: View {
    @Environment(PreferencesStore.self) private var preferencesStore

    var body: some View {
        List {
            Section("Temperature") {
                Picker("Temperature Unit", selection: Binding(
                    get: { preferencesStore.temperatureUnit },
                    set: { newValue in
                        preferencesStore.temperatureUnit = newValue
                        preferencesStore.save()
                    }
                )) {
                    Text("Celsius (°C)").tag(TemperatureUnit.celsius)
                    Text("Fahrenheit (°F)").tag(TemperatureUnit.fahrenheit)
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
        }
        .navigationTitle("Units")
        .navigationBarTitleDisplayMode(.inline)
    }
}
