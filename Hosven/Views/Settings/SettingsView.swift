import SwiftUI

/// Settings scene for v2: General + Profiles tabs. Advanced/sudo cache deferred to v2.1.
struct SettingsView: View {
    @Environment(HostsFileManager.self) private var hostsManager

    var body: some View {
        TabView {
            generalTab
                .tabItem { Label("General", systemImage: "gearshape") }
            profilesTab
                .tabItem { Label("Profiles", systemImage: "person.crop.rectangle.stack") }
        }
        .frame(width: 480, height: 360)
    }

    // MARK: - General

    private var generalTab: some View {
        Form {
            Section("Giao diện") {
                @AppStorage("appearanceMode") var raw: String = AppearanceMode.system.rawValue
                Picker("Chế độ", selection: $raw) {
                    ForEach(AppearanceMode.allCases) { mode in
                        Label(mode.label, systemImage: mode.icon).tag(mode.rawValue)
                    }
                }
                .pickerStyle(.menu)
            }

            Section("Menu Bar") {
                @AppStorage("showMenuBarExtra") var showMenuBar: Bool = true
                Toggle("Hiện ở menu bar", isOn: $showMenuBar)
                Text("Cho phép switch profile nhanh từ menu bar mà không cần mở app.")
                    .font(.dsCaption)
                    .foregroundStyle(.secondary)
            }

            Section("Hệ thống") {
                Text("Hosven v\(appVersion)")
                    .font(.dsCaption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding(DSSpacing.p2)
    }

    // MARK: - Profiles

    private var profilesTab: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Quản lý profiles")
                    .font(.dsHeading)
                Spacer()
                Text("\(hostsManager.profiles.count) profiles")
                    .font(.dsCaption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, DSSpacing.p3)
            .padding(.top, DSSpacing.p3)
            .padding(.bottom, DSSpacing.p2)

            Divider()

            List {
                ForEach(hostsManager.profiles, id: \.id) { profile in
                    profileRow(profile)
                }
            }

            HStack {
                Spacer()
                Text("Để thêm profile mới: dùng + Profile mới ở sidebar")
                    .font(.dsCaption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(DSSpacing.p2)
        }
    }

    private func profileRow(_ profile: Profile) -> some View {
        HStack(spacing: DSSpacing.p2) {
            StatusDot(color: .ds(profile.color), size: 8)
            Text(profile.name)
                .font(.dsBody)
            Spacer()
            if let n = profile.shortcutNumber, n <= 9 {
                Text("⌘\(n)")
                    .font(.dsMonoTiny)
                    .foregroundStyle(.secondary)
            }
            Button(role: .destructive) {
                hostsManager.removeProfile(id: profile.id)
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 2)
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
    }
}
