import SwiftUI
import SharedKit

struct DecisionSelectionView: View {
    @Environment(PreferencesStore.self) private var preferencesStore
    let onContinue: () -> Void

    private let allDecisions: [(DecisionType, String, String)] = [
        (.temperature, "Temperature", "Colder or warmer than yesterday?"),
        (.umbrella, "Umbrella", "Do I need an umbrella?"),
        (.sunscreen, "Sunscreen", "Should I apply SPF?"),
        (.sunglasses, "Sunglasses", "Bright enough for shades?"),
        (.airQuality, "Air Quality", "Should I wear a mask?")
    ]

    var body: some View {
        VStack(spacing: 24) {
            Text("What do you care about?")
                .font(.system(size: 28, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 56)

            VStack(spacing: 16) {
                ForEach(allDecisions, id: \.0) { decisionType, name, subtitle in
                    @Bindable var prefs = preferencesStore
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
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
                                }
                            ))
                            .labelsHidden()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color("Surface"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 16)

            Spacer()

            Button(action: {
                preferencesStore.save()
                onContinue()
            }) {
                Text("Next")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }
}
