import SwiftUI

struct BannerView: View {
    let message: String
    let style: BannerStyle
    @Binding var isVisible: Bool

    enum BannerStyle {
        case warning, info

        var color: Color {
            switch self {
            case .warning: return Color("Warning")
            case .info: return Color("Info")
            }
        }

        var icon: String {
            switch self {
            case .warning: return "exclamationmark.triangle.fill"
            case .info: return "info.circle.fill"
            }
        }
    }

    var body: some View {
        if isVisible {
            HStack(spacing: 8) {
                Image(systemName: style.icon)
                    .foregroundStyle(style.color)
                Text(message)
                    .font(.system(size: 14))
                Spacer()
                Button { isVisible = false } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(12)
            .background(Color("Surface"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)
        }
    }
}
