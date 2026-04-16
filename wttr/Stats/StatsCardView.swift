import SwiftUI

struct StatsCardView: View {
    let category: StatCategory
    let value: String
    let unit: String

    @Environment(\.colorSchemeContrast) private var contrast

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: category.iconName)
                    .font(.system(size: 20))
                    .foregroundStyle(.tint)
                Spacer()
            }
            Spacer()
            Text(value)
                .font(.system(size: 26, weight: .bold))
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(category.displayName)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
            if !unit.isEmpty {
                Text(unit)
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .background(Color("Surface"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityLabel("\(category.displayName): \(value) \(unit)")
        .accessibilityHint("Double-tap to view chart")
        .overlay {
            if contrast == .increased {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.primary.opacity(0.3), lineWidth: 1)
            }
        }
    }
}
