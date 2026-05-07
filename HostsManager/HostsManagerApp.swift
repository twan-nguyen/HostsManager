import SwiftUI

@main
struct HostsManagerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var hostsManager = HostsFileManager()
    @State private var envManager = EnvFileManager()
    @AppStorage("showMenuBarExtra") private var showMenuBarExtra: Bool = true

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    /// Active profile for the menu bar status item title (color dot + name).
    private var activeProfile: Profile? {
        guard let id = hostsManager.activeProfileID else { return nil }
        return hostsManager.profiles.first { $0.id == id }
    }

    var body: some Scene {
        WindowGroup {
            MainWindowView()
                .environment(hostsManager)
                .environment(envManager)
                .frame(minWidth: 880, minHeight: 540)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 980, height: 640)
        .commands {
            CommandGroup(replacing: .undoRedo) {
                Button("Hoàn tác") { hostsManager.undo() }
                    .keyboardShortcut("z", modifiers: .command)
                    .disabled(!hostsManager.canUndo)
                Button("Làm lại") { hostsManager.redo() }
                    .keyboardShortcut("z", modifiers: [.command, .shift])
                    .disabled(!hostsManager.canRedo)
            }
            CommandGroup(after: .textEditing) {
                Button("Tìm kiếm") {
                    hostsManager.isSearchFocused = true
                }
                .keyboardShortcut("f", modifiers: .command)
            }
            CommandMenu("Profile") {
                profileShortcutCommands
                Divider()
                Button("Bỏ chọn profile") {
                    hostsManager.switchProfile(to: nil)
                }
                .keyboardShortcut("0", modifiers: .command)
            }
        }

        Settings {
            SettingsView()
                .environment(hostsManager)
                .environment(envManager)
        }

        // Menu bar quick switch — togglable via Settings.
        // Title shows active profile color dot + name (or generic icon if none active).
        MenuBarExtra(isInserted: $showMenuBarExtra) {
            MenuBarContentView()
                .environment(hostsManager)
        } label: {
            menuBarLabel
        }
        .menuBarExtraStyle(.window)
    }

    /// Status bar label — colored dot + active profile name when set, otherwise a
    /// generic globe icon. Re-renders when activeProfileID changes via SwiftUI.
    @ViewBuilder
    private var menuBarLabel: some View {
        if let profile = activeProfile {
            HStack(spacing: 4) {
                Circle()
                    .fill(Color.ds(profile.color))
                    .frame(width: 8, height: 8)
                Text(profile.name)
                    .font(.system(size: 12))
            }
        } else {
            Image(systemName: "globe")
        }
    }

    /// One menu item per profile (⌘1..⌘9). Hidden in production menu via empty title? — kept visible
    /// so users can discover the shortcut. macOS folds it into the Profile menu.
    @ViewBuilder
    private var profileShortcutCommands: some View {
        ForEach(hostsManager.profiles, id: \.id) { profile in
            if let n = profile.shortcutNumber, (1...9).contains(n) {
                Button("Switch to \(profile.name)") {
                    hostsManager.switchProfile(to: profile.id)
                }
                .keyboardShortcut(KeyEquivalent(Character("\(n)")), modifiers: .command)
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // SwiftUI creates the window after didFinishLaunching, so defer + observe.
        configureWindows()
        NotificationCenter.default.addObserver(
            forName: NSWindow.didBecomeKeyNotification,
            object: nil,
            queue: .main
        ) { _ in self.configureWindows() }
    }

    /// Extend custom TitleBarView all the way to the top of the window so traffic
    /// lights overlay our gradient bg instead of leaving a dark gap above.
    /// Filter to content windows only — MenuBarExtra creates a panel window without
    /// traffic lights, and applying fullSizeContentView to it can corrupt the layout
    /// of the main window when the observer re-fires.
    private func configureWindows() {
        for window in NSApp.windows {
            // standardWindowButton(.closeButton) is non-nil only on real content windows.
            guard window.standardWindowButton(.closeButton) != nil else { continue }
            window.titlebarAppearsTransparent = true
            window.styleMask.insert(.fullSizeContentView)
            window.titleVisibility = .hidden
            window.isMovableByWindowBackground = true
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        releaseAuthorization()
    }
}
