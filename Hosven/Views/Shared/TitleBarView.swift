import SwiftUI

/// 44-pt window header with app identity, tab switcher, and right-side actions.
/// Reference: docs/mockup-reference.md → "TitleBar".
struct TitleBarView: View {
    @Binding var selectedTab: AppTab
    let hostsCount: Int
    let envCount: Int
    var onSearch: () -> Void = {}

    @State private var showAppInfo: Bool = false

    var body: some View {
        // Pin content to the top of a 38pt bar with 4pt top inset so the row's
        // visual baseline (~y=18) lines up with the macOS traffic-light buttons
        // (which sit at y=9..23 / center 16 in the 32pt native titlebar).
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                leftZone
                Spacer(minLength: DSSpacing.p3)
                tabSwitcher
                Spacer(minLength: DSSpacing.p3)
                rightZone
            }
            .padding(.horizontal, DSSpacing.p3)
            .padding(.top, 4)
            Spacer(minLength: 0)
        }
        .frame(height: 38)
        .background(titleBarBackground)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.dsBorderSecondary)
                .frame(height: 0.5)
        }
    }

    // MARK: - Subviews

    /// Empty spacer that reserves room for the macOS traffic-light buttons
    /// (~60pt). App name + icon intentionally hidden — identity surfaces via
    /// the gear button's AppInfoPopover instead.
    private var leftZone: some View {
        Color.clear.frame(width: 60, height: 1)
    }

    private var tabSwitcher: some View {
        HStack(spacing: 2) {
            ForEach(AppTab.allCases) { tab in
                tabButton(tab, count: tab == .hosts ? hostsCount : envCount)
            }
        }
        .padding(2)
        .background(
            RoundedRectangle(cornerRadius: 7)
                .fill(Color.white.opacity(0.05))
        )
    }

    private func tabButton(_ tab: AppTab, count: Int) -> some View {
        let isActive = selectedTab == tab
        return Button {
            selectedTab = tab
        } label: {
            HStack(spacing: 6) {
                Image(systemName: tab.icon)
                    .font(.system(size: 12))
                Text(tab.rawValue)
                    .font(.system(size: 11.5, weight: isActive ? .medium : .regular))
                Text("\(count)")
                    .font(.system(size: 9.5))
                    .padding(.horizontal, 4)
                    .background(
                        Capsule().fill(
                            isActive
                                ? Color.dsProfilePurple.opacity(0.25)
                                : Color.white.opacity(0.08)
                        )
                    )
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 4)
            .foregroundStyle(
                isActive ? Color(hex: "#CECBF6") : Color.dsTextSecondary
            )
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(isActive ? Color.dsProfilePurple.opacity(0.22) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .strokeBorder(
                        isActive ? Color.dsProfilePurple.opacity(0.3) : Color.clear,
                        lineWidth: 0.5
                    )
            )
            // Make the entire padded area clickable. Without this, only the inner
            // text/icon is hit-tested — XCUITest (and small mouse targets) miss the
            // button when the active tab is wider than the inactive one and the
            // user clicks on the padding region.
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(tab.rawValue)
        .accessibilityIdentifier("tab-\(tab.rawValue.lowercased())")
        .accessibilityAddTraits(.isButton)
    }

    private var rightZone: some View {
        HStack(spacing: DSSpacing.p2) {
            Button(action: onSearch) {
                HStack(spacing: 4) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 12))
                    Text("Tìm")
                        .font(.system(size: 11))
                    Text("⌘K")
                        .font(.dsMonoTiny)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.white.opacity(0.08))
                        )
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .foregroundStyle(Color.dsTextSecondary)
                .background(
                    RoundedRectangle(cornerRadius: DSRadius.md)
                        .fill(Color.white.opacity(0.06))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.md)
                        .strokeBorder(Color.dsBorderSecondary, lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)
            .focusEffectDisabled()

            Button {
                showAppInfo.toggle()
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.dsTextSecondary)
                    .padding(4)
            }
            .buttonStyle(.plain)
            .focusEffectDisabled()
            .popover(isPresented: $showAppInfo, arrowEdge: .top) {
                AppInfoPopover(onDismiss: { showAppInfo = false })
            }
        }
    }

    private var titleBarBackground: some View {
        LinearGradient(
            colors: [Color(hex: "#232325"), Color(hex: "#1f1f21")],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

#Preview {
    TitleBarView(
        selectedTab: .constant(.hosts),
        hostsCount: 12,
        envCount: 8
    )
    .frame(width: 980)
    .background(Color.dsBackground)
}
