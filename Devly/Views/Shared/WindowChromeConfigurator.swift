import AppKit
import SwiftUI

/// Reaches up to the hosting NSWindow once it exists and applies our custom chrome:
/// transparent title bar, full-size content view, traffic lights overlaid on our
/// TitleBarView gradient. This must run from inside the SwiftUI view tree (not
/// AppDelegate) because NSApp.windows iteration at didFinishLaunching can miss
/// the WindowGroup window — viewDidMoveToWindow is the reliable hook.
struct WindowChromeConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView { ProbeView() }
    func updateNSView(_ nsView: NSView, context: Context) {}

    /// Apply our custom chrome to `window`. Exposed for tests.
    /// Only sets fields whose value differs from desired — re-applying otherwise
    /// drops pending click events.
    static func configure(_ window: NSWindow) {
        let desiredMask: NSWindow.StyleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
        if window.styleMask != desiredMask {
            window.styleMask = desiredMask
        }
        if !window.titlebarAppearsTransparent { window.titlebarAppearsTransparent = true }
        if window.titleVisibility != .hidden { window.titleVisibility = .hidden }
        // Drag only from the titlebar (where traffic lights live) — not the body.
        // With fullSizeContentView the titlebar is still hit-tested for window
        // dragging even though our custom TitleBarView paints over it.
        if window.isMovableByWindowBackground { window.isMovableByWindowBackground = false }
        if window.toolbar != nil { window.toolbar = nil }
        ensureTitlebarVisible(window)
    }

    /// Lightweight re-assertion of titlebar visibility (no styleMask reset).
    /// Used by KVO callback when NavigationSplitView hides the container.
    static func ensureTitlebarVisible(_ window: NSWindow) {
        let close = window.standardWindowButton(.closeButton)
        if let titlebarContainer = close?.superview?.superview {
            if titlebarContainer.isHidden { titlebarContainer.isHidden = false }
            if titlebarContainer.alphaValue != 1.0 { titlebarContainer.alphaValue = 1.0 }
        }
        if close?.isHidden == true { close?.isHidden = false }
        if window.standardWindowButton(.miniaturizeButton)?.isHidden == true {
            window.standardWindowButton(.miniaturizeButton)?.isHidden = false
        }
        if window.standardWindowButton(.zoomButton)?.isHidden == true {
            window.standardWindowButton(.zoomButton)?.isHidden = false
        }
    }

    private final class ProbeView: NSView {
        private var keyObserver: NSObjectProtocol?
        private var hiddenKVO: NSKeyValueObservation?
        private var alphaKVO: NSKeyValueObservation?

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            detachObservers()
            guard let window = self.window, !(window is NSPanel) else { return }
            WindowChromeConfigurator.configure(window)

            // Re-apply when window becomes key.
            keyObserver = NotificationCenter.default.addObserver(
                forName: NSWindow.didBecomeKeyNotification,
                object: window,
                queue: .main
            ) { [weak window] _ in
                guard let window else { return }
                WindowChromeConfigurator.configure(window)
            }

            // KVO on NSTitlebarContainerView's isHidden + alphaValue: NavigationSplitView
            // (used by EnvView) hides the container when it installs its toolbar.
            // Catch every hide attempt and immediately revert.
            if let container = window.standardWindowButton(.closeButton)?.superview?.superview {
                hiddenKVO = container.observe(\.isHidden, options: [.new]) { view, change in
                    if change.newValue == true {
                        view.isHidden = false
                    }
                }
                alphaKVO = container.observe(\.alphaValue, options: [.new]) { view, change in
                    if let v = change.newValue, v < 1.0 {
                        view.alphaValue = 1.0
                    }
                }
            }
        }

        private func detachObservers() {
            if let keyObserver {
                NotificationCenter.default.removeObserver(keyObserver)
                self.keyObserver = nil
            }
            hiddenKVO?.invalidate(); hiddenKVO = nil
            alphaKVO?.invalidate(); alphaKVO = nil
        }

        deinit { detachObservers() }
    }
}
