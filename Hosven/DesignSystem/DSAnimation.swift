import SwiftUI

/// Centralized animation tokens. Spring-based curves feel more natural than
/// linear easing for UI motion — slight rebound on settle reads as physical
/// rather than mechanical. Reference: docs/mockup-reference.md → "Motion".
extension Animation {
    /// Snappy reaction (~180 ms perceived). Hover highlights, toggle knobs,
    /// row backgrounds, button press feedback.
    static let dsSnappy = Animation.spring(response: 0.28, dampingFraction: 0.85)

    /// Standard transition (~250 ms perceived). Profile/tab switching, selection
    /// highlight, filter changes, content swaps. Slight settle for readability.
    static let dsSmooth = Animation.spring(response: 0.38, dampingFraction: 0.86)

    /// Toast / floating panels (~450 ms). More overshoot for noticeable arrival.
    static let dsBouncy = Animation.spring(response: 0.45, dampingFraction: 0.78)

    /// Modal / sheet content fade (~200 ms easeOut). Use when a spring would
    /// over-animate text-heavy content.
    static let dsFade = Animation.easeOut(duration: 0.20)
}
