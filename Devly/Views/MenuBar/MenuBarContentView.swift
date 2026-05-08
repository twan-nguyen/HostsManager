import SwiftUI

/// MenuBarExtra dropdown content. Two actions: open the main window, quit.
/// Profile switching has moved entirely into the in-app sidebar to keep the
/// menu bar minimal.
struct MenuBarContentView: View {
    var body: some View {
        Button("Mở Devly") {
            NSApp.activate(ignoringOtherApps: true)
            for window in NSApp.windows where window.canBecomeKey {
                window.makeKeyAndOrderFront(nil)
                return
            }
        }
        .keyboardShortcut("o", modifiers: .command)

        Button("Thoát") {
            NSApp.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: .command)
    }
}
