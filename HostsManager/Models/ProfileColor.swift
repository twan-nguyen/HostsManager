import Foundation

/// Predefined color choices for `Profile`. Hex values match design tokens in `docs/mockup-reference.md`.
enum ProfileColor: String, CaseIterable, Identifiable, Codable, Hashable {
    case purple
    case green
    case amber
    case blue
    case red

    var id: String { rawValue }

    /// Hex string (no `#` prefix) matching design system tokens.
    var hex: String {
        switch self {
        case .purple: return "7f77dd"
        case .green:  return "5dcaa5"
        case .amber:  return "ef9f27"
        case .blue:   return "378ADD"
        case .red:    return "e24b4a"
        }
    }

    var displayName: String {
        switch self {
        case .purple: return "Purple"
        case .green:  return "Green"
        case .amber:  return "Amber"
        case .blue:   return "Blue"
        case .red:    return "Red"
        }
    }
}
