import SwiftUI

// MARK: - Card

/// 0.5-pt border + sidebar background + rounded corners. Used for active profile card, panels.
struct DSCardModifier: ViewModifier {
    var background: Color = .dsBackgroundSidebar
    var radius: CGFloat = DSRadius.lg

    func body(content: Content) -> some View {
        content
            .background(background)
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .strokeBorder(Color.dsBorderSecondary, lineWidth: 0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: radius))
    }
}

// MARK: - Row hover

/// Subtle white-overlay hover state for list rows. Animates 150 ms ease-in-out.
struct DSRowHoverModifier: ViewModifier {
    @State private var isHovering = false

    func body(content: Content) -> some View {
        content
            .background(isHovering ? Color.white.opacity(0.04) : Color.clear)
            .animation(.easeInOut(duration: 0.15), value: isHovering)
            .onHover { isHovering = $0 }
    }
}

// MARK: - Sidebar item

/// Padding + radius + selectable state for sidebar entries.
struct DSSidebarItemModifier: ViewModifier {
    let isSelected: Bool

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, DSSpacing.p2)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.md)
                    .fill(isSelected ? Color.white.opacity(0.06) : Color.clear)
            )
    }
}

// MARK: - Convenience

extension View {
    func dsCard(background: Color = .dsBackgroundSidebar, radius: CGFloat = DSRadius.lg) -> some View {
        modifier(DSCardModifier(background: background, radius: radius))
    }

    func dsRowHover() -> some View {
        modifier(DSRowHoverModifier())
    }

    func dsSidebarItem(isSelected: Bool) -> some View {
        modifier(DSSidebarItemModifier(isSelected: isSelected))
    }
}
