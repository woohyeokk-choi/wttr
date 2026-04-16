import SwiftUI
import SharedKit

struct DecisionPreferencesView: View {
    @Environment(PreferencesStore.self) private var preferencesStore

    private let allDecisions: [(DecisionType, String, String)] = [
        (.temperature, "Temperature", "Colder or warmer than yesterday?"),
        (.umbrella, "Umbrella", "Do I need an umbrella?"),
        (.sunscreen, "Sunscreen", "Should I apply SPF?"),
        (.sunglasses, "Sunglasses", "Bright enough for shades?"),
        (.airQuality, "Air Quality", "Should I wear a mask?")
    ]

    var body: some View {
        List {
            ForEach(allDecisions, id: \.0) { decisionType, name, subtitle in
                HStack {
                    Image(systemName: decisionType.iconName)
                        .font(.system(size: 20))
                        .foregroundStyle(.tint)
                        .frame(width: 32)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(name)
                            .font(.system(size: 17, weight: .medium))
                        Text(subtitle)
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if decisionType == .temperature {
                        Toggle("", isOn: .constant(true))
                            .disabled(true)
                            .labelsHidden()
                    } else {
                        Toggle("", isOn: Binding(
                            get: { preferencesStore.enabledDecisions.contains(decisionType) },
                            set: { isOn in
                                if isOn {
                                    preferencesStore.enabledDecisions.insert(decisionType)
                                } else {
                                    preferencesStore.enabledDecisions.remove(decisionType)
                                }
                                preferencesStore.save()
                            }
                        ))
                        .labelsHidden()
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Decision Cards")
        .navigationBarTitleDisplayMode(.inline)
    }
}
