import SwiftUI

// MARK: - Hex initializer

extension Color {
    /// Construct a Color from a hex string (`"#1a1a1c"`, `"1a1a1c"`, `"#fff"`, `"FFAA"` for ARGB).
    /// Falls back to clear if the string is malformed — design tokens use literals so this is safe.
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch cleaned.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (0, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Design tokens (dark mode primary)
//
// Reference: docs/mockup-reference.md sections "Color contrast verification".

extension Color {
    // Backgrounds
    static let dsBackground          = Color(hex: "#1a1a1c")
    static let dsBackgroundSidebar   = Color(hex: "#161618")
    static let dsBackgroundBreadcrumb = Color(hex: "#1c1c1e")

    // Borders (white opacity)
    static let dsBorderTertiary  = Color.white.opacity(0.06)
    static let dsBorderSecondary = Color.white.opacity(0.08)
    static let dsBorderPrimary   = Color.white.opacity(0.12)

    // Text (white opacity)
    static let dsTextPrimary   = Color.white.opacity(0.92)
    static let dsTextSecondary = Color.white.opacity(0.55)
    static let dsTextTertiary  = Color.white.opacity(0.35)

    // Profile colors — match `ProfileColor` enum hex
    static let dsProfilePurple = Color(hex: "#7f77dd")
    static let dsProfileGreen  = Color(hex: "#5dcaa5")
    static let dsProfileAmber  = Color(hex: "#ef9f27")
    static let dsProfileBlue   = Color(hex: "#378ADD")
    static let dsProfileRed    = Color(hex: "#e24b4a")

    // Semantic — IP addressing
    static let dsIPLocalhost = Color(hex: "#F09595")
    static let dsIPRemote    = Color(hex: "#97C459")

    // Semantic — Env
    static let dsValueAmber    = Color(hex: "#FAC775")
    static let dsResolvedGreen = Color(hex: "#5dcaa5")
}

// MARK: - ProfileColor → Color bridge

extension Color {
    /// Resolve a `ProfileColor` to its design-system `Color`.
    static func ds(_ profileColor: ProfileColor) -> Color {
        switch profileColor {
        case .purple: return .dsProfilePurple
        case .green:  return .dsProfileGreen
        case .amber:  return .dsProfileAmber
        case .blue:   return .dsProfileBlue
        case .red:    return .dsProfileRed
        }
    }
}
