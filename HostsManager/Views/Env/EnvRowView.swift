import SwiftUI

/// Shared column widths for the env entry list. Referenced by `EnvFilePane`'s
/// `Table` column `.width(...)` modifiers.
enum EnvRowLayout {
    static let toggle: CGFloat = 32
    static let key: CGFloat = 200
    static let menu: CGFloat = 28
}
