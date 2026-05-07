import AppKit

/// Applies syntax-highlight attributes to a hosts-file `NSTextStorage` in place.
/// Token rules: tag markers (purple), comments (gray italic), localhost IPs (red),
/// remote IPs (green), hostnames (primary text), disabled entries (dimmed).
///
/// Usage: call `apply(to:)` after every text change. For typical hosts files (<2k lines)
/// the full-document scan is fast enough; we skip incremental highlighting for simplicity.
enum HostsSyntaxHighlighter {
    /// Color tokens — kept private to avoid duplicating DesignSystem; raw editor is the only consumer.
    private static let colorComment   = NSColor(srgbRed: 0.55, green: 0.55, blue: 0.55, alpha: 1.0)
    private static let colorTagMarker = NSColor(srgbRed: 0.498, green: 0.467, blue: 0.867, alpha: 1.0) // #7F77DD
    private static let colorIPLocal   = NSColor(srgbRed: 0.941, green: 0.584, blue: 0.584, alpha: 1.0) // #F09595
    private static let colorIPRemote  = NSColor(srgbRed: 0.592, green: 0.769, blue: 0.349, alpha: 1.0) // #97C459
    private static let colorHostname  = NSColor.labelColor
    private static let colorDisabled  = NSColor.tertiaryLabelColor

    private static let tagMarkerPattern = try! NSRegularExpression(pattern: #"^##\s*\[/?tag:[^\]]+\]\s*$"#)
    private static let ipv4Pattern      = try! NSRegularExpression(pattern: #"^\d{1,3}(\.\d{1,3}){3}$"#)
    private static let localhostIPv4    = "127.0.0.1"
    private static let localhostIPv6    = "::1"

    static func apply(to storage: NSTextStorage, font: NSFont) {
        let fullRange = NSRange(location: 0, length: storage.length)
        guard fullRange.length > 0 else { return }

        storage.beginEditing()
        defer { storage.endEditing() }

        // Reset baseline — clear stale color/font so re-runs don't compound.
        storage.removeAttribute(.foregroundColor, range: fullRange)
        storage.removeAttribute(.font, range: fullRange)
        storage.addAttribute(.foregroundColor, value: NSColor.labelColor, range: fullRange)
        storage.addAttribute(.font, value: font, range: fullRange)

        let text = storage.string as NSString
        var lineStart = 0
        while lineStart < text.length {
            let lineRange = text.lineRange(for: NSRange(location: lineStart, length: 0))
            highlightLine(in: storage, lineRange: lineRange, font: font)
            lineStart = NSMaxRange(lineRange)
        }
    }

    private static func highlightLine(in storage: NSTextStorage, lineRange: NSRange, font: NSFont) {
        let nsLine = (storage.string as NSString).substring(with: lineRange)
        let trimmed = nsLine.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return }

        // Tag marker — full line in purple.
        if tagMarkerPattern.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)) != nil {
            storage.addAttribute(.foregroundColor, value: colorTagMarker, range: lineRange)
            return
        }

        let isDisabledEntry = isDisabledHostsLine(trimmed)
        let isPureComment = trimmed.hasPrefix("#") && !isDisabledEntry

        if isPureComment {
            storage.addAttribute(.foregroundColor, value: colorComment, range: lineRange)
            if let italic = NSFontManager.shared.font(withFamily: font.familyName ?? "Menlo",
                                                     traits: .italicFontMask,
                                                     weight: 5,
                                                     size: font.pointSize) {
                storage.addAttribute(.font, value: italic, range: lineRange)
            }
            return
        }

        // Active or disabled entry: tokenize "ip hostname [# inline-comment]"
        let workingLine = isDisabledEntry ? String(trimmed.drop(while: { $0 == "#" || $0 == " " })) : trimmed
        let leadingOffset = lineRange.location + (nsLine as NSString).range(of: workingLine).location

        let tokens = tokenize(workingLine)
        for token in tokens {
            let absoluteRange = NSRange(location: leadingOffset + token.offset, length: token.length)
            guard NSMaxRange(absoluteRange) <= NSMaxRange(lineRange) else { continue }
            let color = colorFor(token: token, disabled: isDisabledEntry)
            storage.addAttribute(.foregroundColor, value: color, range: absoluteRange)
        }

        if isDisabledEntry {
            storage.addAttribute(.foregroundColor, value: colorDisabled, range: lineRange)
        }
    }

    // MARK: - Tokenization

    private struct Token {
        enum Kind { case ipLocal, ipRemote, hostname, comment, other }
        let kind: Kind
        let offset: Int
        let length: Int
    }

    private static func colorFor(token: Token, disabled: Bool) -> NSColor {
        if disabled { return colorDisabled }
        switch token.kind {
        case .ipLocal:  return colorIPLocal
        case .ipRemote: return colorIPRemote
        case .hostname: return colorHostname
        case .comment:  return colorComment
        case .other:    return colorHostname
        }
    }

    /// Tokenize a single line "ip hostname [extra]... [# comment]". Best-effort,
    /// not a full grammar — IP / hostname / inline-comment are the only spans we color.
    private static func tokenize(_ line: String) -> [Token] {
        var tokens: [Token] = []
        let ns = line as NSString

        // Split off inline comment first.
        var workingLine = line
        var workingLength = ns.length
        if let hashIdx = line.firstIndex(of: "#") {
            let pos = line.distance(from: line.startIndex, to: hashIdx)
            workingLine = String(line[line.startIndex..<hashIdx])
            workingLength = pos
            tokens.append(Token(kind: .comment, offset: pos, length: ns.length - pos))
        }

        // Walk whitespace-separated tokens.
        let working = (workingLine as NSString).substring(with: NSRange(location: 0, length: workingLength))
        var idx = 0
        var firstToken = true
        let chars = Array(working)
        while idx < chars.count {
            // Skip whitespace
            while idx < chars.count, chars[idx].isWhitespace { idx += 1 }
            let start = idx
            while idx < chars.count, !chars[idx].isWhitespace { idx += 1 }
            if start == idx { break }
            let len = idx - start
            let segment = String(chars[start..<idx])

            if firstToken {
                let kind: Token.Kind = isLocalhost(segment) ? .ipLocal : (isIPv4(segment) || segment.contains(":")) ? .ipRemote : .other
                tokens.append(Token(kind: kind, offset: start, length: len))
                firstToken = false
            } else {
                tokens.append(Token(kind: .hostname, offset: start, length: len))
            }
        }
        return tokens
    }

    private static func isLocalhost(_ s: String) -> Bool {
        s == localhostIPv4 || s == localhostIPv6
    }

    private static func isIPv4(_ s: String) -> Bool {
        ipv4Pattern.firstMatch(in: s, range: NSRange(s.startIndex..., in: s)) != nil
    }

    /// True when a line starts with `#` followed by something that parses as `ip hostname`.
    /// Distinguishes a disabled host entry from a pure comment line.
    private static func isDisabledHostsLine(_ trimmed: String) -> Bool {
        guard trimmed.hasPrefix("#") else { return false }
        let body = String(trimmed.drop(while: { $0 == "#" || $0 == " " }))
        let parts = body.split(whereSeparator: \.isWhitespace)
        guard parts.count >= 2 else { return false }
        let head = String(parts[0])
        return isIPv4(head) || head.contains(":")
    }
}
