import SwiftUI

/// Pill indicating where a host/env entry comes from.
/// Reference: docs/mockup-reference.md → "Source badge".
struct SourceBadge: View {
    enum Kind {
        case profile(name: String)
        case remote
        case local
        case off

        var label: String {
            switch self {
            case .profile(let name): return name.uppercased()
            case .remote: return "REMOTE"
            case .local:  return "LOCAL"
            case .off:    return "OFF"
            }
        }

        var background: Color {
            switch self {
            case .profile: return Color.dsProfilePurple.opacity(0.15)
            case .remote:  return Color.dsIPRemote.opacity(0.12)
            case .local:   return Color.white.opacity(0.06)
            case .off:     return Color.white.opacity(0.05)
            }
        }

        var foreground: Color {
            switch self {
            case .profile: return Color(hex: "#AFA9EC")
            case .remote:  return Color(hex: "#C0DD97")
            case .local:   return Color.dsTextSecondary
            case .off:     return Color.dsTextTertiary
            }
        }
    }

    let kind: Kind

    var body: some View {
        Text(kind.label)
            .font(.system(size: 9.5, weight: .medium))
            .foregroundStyle(kind.foreground)
            .padding(.horizontal, 5)
            .padding(.vertical, 1)
            .background(
                RoundedRectangle(cornerRadius: 3)
                    .fill(kind.background)
            )
    }
}

#Preview("Variants") {
    HStack(spacing: 8) {
        SourceBadge(kind: .profile(name: "Release"))
        SourceBadge(kind: .remote)
        SourceBadge(kind: .local)
        SourceBadge(kind: .off)
    }
    .padding()
    .background(Color.dsBackground)
}
