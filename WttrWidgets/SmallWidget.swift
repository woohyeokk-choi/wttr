import SwiftUI
import SharedKit

/// Small (systemSmall) — Decision-first.
///
/// Top decision headline is the hero (2-line bold). Supporting decision icons
/// fill a compact row below. Location/temperature are contextual footnotes.
struct WttrSmallWidgetView: View {
    let entry: WeatherWidgetEntry

    private var primary: WidgetDecision? { entry.decisions.first }
    private var others: [WidgetDecision] { Array(entry.decisions.dropFirst().prefix(3)) }

    var body: some View {
        ZStack {
            Color("Surface")

            VStack(alignment: .leading, spacing: 6) {
                // Primary decision — hero
                if let primary {
                    HStack(spacing: 6) {
                        Image(systemName: primary.icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(severityColor(primary.severity))
                        Text(primary.shortLabel)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Text(primary.headline)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 2)

                // Other decisions — compact icon row
                if !others.isEmpty {
                    HStack(spacing: 10) {
                        ForEach(others, id: \.type) { d in
                            Image(systemName: d.icon)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(severityColor(d.severity))
                        }
                    }
                }

                // Context footer — location + temp
                HStack(spacing: 4) {
                    Text(entry.location)
                        .lineLimit(1)
                    Text("·")
                    Text(entry.temperature)
                        .fontWeight(.semibold)
                }
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            if entry.isLocationBlocked {
                // Home-screen version of the "location is off" badge. Widget
                // tap area deep-links into the app, which in turn routes to
                // Settings from the empty-state screen.
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "location.slash.fill")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(6)
                            .background(Circle().fill(Color.red))
                            .padding(6)
                    }
                    Spacer()
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(accessibilityLabel))
    }

    private var accessibilityLabel: String {
        let primaryLabel = entry.decisions.first.map { "\($0.headline). " } ?? ""
        let others = entry.decisions.dropFirst().map(\.shortLabel).joined(separator: ", ")
        return primaryLabel + "Also: \(others). \(entry.location), \(entry.temperature)."
    }

    private func severityColor(_ s: DecisionSeverity) -> Color {
        switch s {
        case .safe: return Color("Safe")
        case .caution: return Color("Caution")
        case .warning: return Color("Warning")
        case .danger: return Color("Danger")
        }
    }
}
