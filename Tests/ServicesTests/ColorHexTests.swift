import Testing
import SwiftUI
@testable import Hosven

@Suite("Color hex initializer")
struct ColorHexTests {
    /// Pull RGBA out of the SwiftUI `Color` for round-trip checks.
    private func rgba(_ color: Color) -> (r: Double, g: Double, b: Double, a: Double) {
        let ns = NSColor(color).usingColorSpace(.sRGB)!
        return (ns.redComponent, ns.greenComponent, ns.blueComponent, ns.alphaComponent)
    }

    @Test("6-digit hex parses to expected RGB")
    func sixDigitHex() {
        let c = Color(hex: "#ff8800")
        let (r, g, b, _) = rgba(c)
        #expect(abs(r - 1.0) < 0.01)
        #expect(abs(g - 0x88 / 255.0) < 0.01)
        #expect(abs(b - 0.0) < 0.01)
    }

    @Test("3-digit shorthand expands correctly")
    func threeDigitHex() {
        let c = Color(hex: "#f80")
        let (r, g, b, _) = rgba(c)
        #expect(abs(r - 1.0) < 0.01)
        #expect(abs(g - 0x88 / 255.0) < 0.01)
        #expect(abs(b - 0.0) < 0.01)
    }

    @Test("Hex without # prefix still parses")
    func noHashPrefix() {
        let c = Color(hex: "1a1a1c")
        let (r, _, _, _) = rgba(c)
        #expect(abs(r - 0x1a / 255.0) < 0.01)
    }

    @Test("Malformed hex falls back to clear (alpha 0)")
    func malformedFallsBackToClear() {
        let c = Color(hex: "zzzz")
        let (_, _, _, a) = rgba(c)
        #expect(a < 0.01)
    }

    @Test("Profile color tokens match ProfileColor.hex")
    func profileTokensMatchEnum() {
        let pairs: [(ProfileColor, Color)] = [
            (.purple, .dsProfilePurple),
            (.green,  .dsProfileGreen),
            (.amber,  .dsProfileAmber),
            (.blue,   .dsProfileBlue),
            (.red,    .dsProfileRed),
        ]
        for (pc, token) in pairs {
            let (r, g, b, _) = rgba(token)
            let (er, eg, eb, _) = rgba(Color(hex: pc.hex))
            #expect(abs(r - er) < 0.01)
            #expect(abs(g - eg) < 0.01)
            #expect(abs(b - eb) < 0.01)
        }
    }

    @Test("Color.ds(profileColor) bridges to design tokens")
    func dsBridgeReturnsTokens() {
        let (r1, _, _, _) = rgba(Color.ds(.purple))
        let (r2, _, _, _) = rgba(Color.dsProfilePurple)
        #expect(abs(r1 - r2) < 0.01)
    }
}
