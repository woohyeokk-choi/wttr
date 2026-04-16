import SwiftUI
import SharedKit

struct DecisionCardView: View {
    let decision: any Decision
    @Environment(\.colorSchemeContrast) private var contrast

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(decision.type.displayName.uppercased())
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
                Spacer()
                Image(systemName: decision.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(iconColor)
            }
            Text(decision.headline)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(decision.severity == .danger ? Color("Danger") : .primary)
            Text(decision.description)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            if contrast == .increased {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.primary.opacity(0.3), lineWidth: 1)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(decision.type.displayName): \(decision.headline). \(decision.severity.displayName)")
        .accessibilityHint(decision.description)
    }

    private var iconColor: Color {
        switch decision.severity {
        case .safe: return Color("Safe")
        case .caution: return Color("Caution")
        case .warning: return Color("Warning")
        case .danger: return Color("Danger")
        }
    }

    private var cardBackground: Color {
        decision.severity == .danger ? Color("DangerTint") : Color("Surface")
    }
}
