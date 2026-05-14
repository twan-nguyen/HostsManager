import AppKit
import Observation
import Sparkle

/// Thin wrapper around `SPUStandardUpdaterController`. Sparkle owns all UI
/// (no-update toast, install dialog, progress, relaunch), so this wrapper only
/// exposes a single `checkForUpdates()` entry point used by the title-bar popover.
///
/// Created once at app startup (see `HosvenApp`) so Sparkle's scheduled
/// 24h background check stays alive across popover open/close.
@Observable
@MainActor
final class AutoUpdater {
    private let controller: SPUStandardUpdaterController

    init() {
        controller = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }

    /// User-initiated check. Sparkle handles all subsequent UI.
    func checkForUpdates() {
        controller.checkForUpdates(nil)
    }
}
