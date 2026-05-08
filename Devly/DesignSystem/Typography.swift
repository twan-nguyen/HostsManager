import SwiftUI

// Reference: docs/mockup-reference.md → "Typography".
extension Font {
    /// 17px medium — primary titles (window header, sheet title).
    static let dsTitle = Font.system(size: 17, weight: .medium)

    /// 15px medium — section headings, list group titles.
    static let dsHeading = Font.system(size: 15, weight: .medium)

    /// 12px regular — body copy, labels.
    static let dsBody = Font.system(size: 12, weight: .regular)

    /// 11px regular — captions, metadata.
    static let dsCaption = Font.system(size: 11, weight: .regular)

    /// 10px medium uppercase — sidebar section headers, source badges.
    static let dsLabel = Font.system(size: 10, weight: .medium).smallCaps()

    /// SF Mono 11px — IPs, hostnames, env keys.
    static let dsMono = Font.system(size: 11, weight: .regular, design: .monospaced)

    /// SF Mono 10.5px — raw editor body.
    static let dsMonoSmall = Font.system(size: 10.5, weight: .regular, design: .monospaced)

    /// SF Mono 9px — resolved value preview line, footnotes.
    static let dsMonoTiny = Font.system(size: 9, weight: .regular, design: .monospaced)
}
