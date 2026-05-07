import SwiftUI

/// Pill: color dot + name + optional ⌘N shortcut hint.
/// Reference: docs/mockup-reference.md → "Breadcrumb" → "Profile badge".
struct ProfileBadge: View {
    let profile: Profile
    var showShortcut: Bool = true
    var glow: Bool = false

    var body: some View {
        HStack(spacing: DSSpacing.p2) {
            StatusDot(color: .ds(profile.color), glow: glow)

            Text(profile.name)
                .font(.system(size: 11.5, weight: .medium))
                .foregroundStyle(profileTextColor)

            if showShortcut, let n = profile.shortcutNumber, n <= 9 {
                Text("⌘\(n)")
                    .font(.dsMonoTiny)
                    .foregroundStyle(Color.dsTextTertiary)
            }
        }
        .padding(.horizontal, DSSpacing.p2)
        .padding(.vertical, 2)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.sm)
                .fill(Color.ds(profile.color).opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DSRadius.sm)
                .strokeBorder(Color.ds(profile.color).opacity(0.3), lineWidth: 0.5)
        )
    }

    private var profileTextColor: Color {
        // Lighter tint of profile color — matches mockup's "#CECBF6" for purple.
        // Approximation via opacity blend; good enough vs hand-tuning per color.
        Color.white.opacity(0.85)
    }
}

#Preview("Defaults") {
    VStack(alignment: .leading, spacing: 8) {
        ProfileBadge(profile: .release, glow: true)
        ProfileBadge(profile: .production)
        ProfileBadge(profile: .master, showShortcut: false)
    }
    .padding()
    .background(Color.dsBackground)
}
