import SwiftUI

/// Red-slash indicator shown when the system has blocked location access
/// (denied/restricted). Tapping deep-links into the system Settings page for
/// the app so the user can re-enable "While Using App".
struct LocationBlockedBadge: View {
    enum Size {
        case compact   // header / toolbar
        case prominent // empty-state / alert area

        var iconSize: CGFloat {
            switch self {
            case .compact: return 18
            case .prominent: return 44
            }
        }

        var paddingH: CGFloat {
            switch self {
            case .compact: return 8
            case .prominent: return 16
            }
        }

        var paddingV: CGFloat {
            switch self {
            case .compact: return 6
            case .prominent: return 12
            }
        }
    }

    let size: Size
    var showsLabel: Bool = true

    var body: some View {
        Button {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: size == .prominent ? 10 : 6) {
                Image(systemName: "location.slash.fill")
                    .font(.system(size: size.iconSize, weight: .semibold))
                    .foregroundStyle(.white)
                if showsLabel {
                    Text(size == .prominent ? "Location is off — Tap to enable" : "Off")
                        .font(.system(size: size == .prominent ? 15 : 12, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, size.paddingH)
            .padding(.vertical, size.paddingV)
            .background(
                RoundedRectangle(cornerRadius: size == .prominent ? 12 : 8, style: .continuous)
                    .fill(Color.red)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Location access is off. Tap to open Settings.")
    }
}

#Preview("Compact") {
    LocationBlockedBadge(size: .compact)
        .padding()
}

#Preview("Prominent") {
    LocationBlockedBadge(size: .prominent)
        .padding()
}
