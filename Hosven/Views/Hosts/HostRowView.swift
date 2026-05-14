import SwiftUI
import CoreGraphics

/// Shared column widths for the host list. Referenced by `HostsView`'s
/// `Table` column `.width(...)` modifiers.
enum HostRowLayout {
    static let toggle: CGFloat = 32
    static let ip: CGFloat = 130
    static let source: CGFloat = 92
    static let menu: CGFloat = 28
}
