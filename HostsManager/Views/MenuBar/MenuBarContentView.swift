import SwiftUI

/// MenuBarExtra dropdown content. Shows active profile + quick switch list +
/// "Open Hosts Manager" action. Wired to `HostsFileManager` via environment.
/// Reference: plans/260507-1022-v2-redesign/v2.1-quick-switch.md → Phase 2.
struct MenuBarContentView: View {
    @Environment(HostsFileManager.self) private var hostsManager
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            activeSection
            Divider()
            switchSection
            Divider()
            actionsSection
        }
        .frame(width: 260)
        .padding(.vertical, 6)
    }

    // MARK: - Active profile

    @ViewBuilder
    private var activeSection: some View {
        sectionHeader("PROFILE HIỆN TẠI")
        if let active = activeProfile {
            HStack(spacing: 8) {
                StatusDot(color: .ds(active.color), size: 8, glow: true)
                Text(active.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.primary)
                Spacer()
                Text("đang bật")
                    .font(.system(size: 10.5))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        } else {
            Text("Chưa chọn profile nào")
                .font(.system(size: 11.5))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
        }
    }

    // MARK: - Quick switch

    @ViewBuilder
    private var switchSection: some View {
        sectionHeader("CHUYỂN NHANH")
        if otherProfiles.isEmpty {
            Text("Không có profile khác")
                .font(.system(size: 11.5))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
        } else {
            ForEach(otherProfiles, id: \.id) { profile in
                MenuBarProfileRow(profile: profile) {
                    hostsManager.switchProfile(to: profile.id)
                }
            }
        }

        if hostsManager.activeProfileID != nil {
            MenuBarActionRow(
                icon: "circle.slash",
                label: "Bỏ chọn profile",
                shortcut: "⌘0"
            ) {
                hostsManager.switchProfile(to: nil)
            }
        }
    }

    // MARK: - Actions

    @ViewBuilder
    private var actionsSection: some View {
        MenuBarActionRow(icon: "macwindow", label: "Mở Hosts Manager", shortcut: "⌘O") {
            NSApp.activate(ignoringOtherApps: true)
            for window in NSApp.windows where window.canBecomeKey {
                window.makeKeyAndOrderFront(nil)
                return
            }
        }
        MenuBarActionRow(icon: "power", label: "Thoát", shortcut: "⌘Q") {
            NSApp.terminate(nil)
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 9.5, weight: .semibold))
            .foregroundStyle(.tertiary)
            .padding(.horizontal, 12)
            .padding(.top, 6)
            .padding(.bottom, 2)
    }

    private var activeProfile: Profile? {
        guard let id = hostsManager.activeProfileID else { return nil }
        return hostsManager.profiles.first { $0.id == id }
    }

    private var otherProfiles: [Profile] {
        hostsManager.profiles.filter { $0.id != hostsManager.activeProfileID }
    }
}

/// Single profile row with hover highlight. Click switches to it.
private struct MenuBarProfileRow: View {
    let profile: Profile
    let onTap: () -> Void
    @State private var hovering = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                StatusDot(color: .ds(profile.color), size: 7)
                Text(profile.name)
                    .font(.system(size: 12.5))
                    .foregroundStyle(.primary)
                Spacer()
                if let n = profile.shortcutNumber, (1...9).contains(n) {
                    Text("⌘\(n)")
                        .font(.system(size: 10.5).monospacedDigit())
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(hovering ? Color.accentColor.opacity(0.18) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
    }
}

private struct MenuBarActionRow: View {
    let icon: String
    let label: String
    let shortcut: String?
    let action: () -> Void
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .frame(width: 14)
                    .foregroundStyle(.secondary)
                Text(label)
                    .font(.system(size: 12.5))
                Spacer()
                if let shortcut {
                    Text(shortcut)
                        .font(.system(size: 10.5))
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(hovering ? Color.accentColor.opacity(0.18) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
    }
}
