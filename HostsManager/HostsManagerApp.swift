import SwiftUI

@main
struct HostsManagerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var hostsManager = HostsFileManager()
    @State private var envManager = EnvFileManager()

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
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
            CommandGroup(after: .textEditing) {
                Button("Tìm kiếm") {
                    hostsManager.isSearchFocused = true
                }
                .keyboardShortcut("f", modifiers: .command)
            }
        }

        Settings {
            EmptyView()
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
    private func configureWindows() {
        for window in NSApp.windows {
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
