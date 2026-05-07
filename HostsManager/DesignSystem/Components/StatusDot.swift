import SwiftUI

/// 5-pt filled circle. Optional outer glow indicates "active" / live state.
/// Used in profile badges, repo modified indicator, status bar.
struct StatusDot: View {
    let color: Color
    var size: CGFloat = 5
    var glow: Bool = false

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .stroke(color.opacity(0.4), lineWidth: glow ? 1.2 : 0)
                    .scaleEffect(glow ? 2.0 : 1.0)
                    .opacity(glow ? 1 : 0)
            )
    }
}

#Preview("Variants") {
    HStack(spacing: 16) {
        StatusDot(color: .dsProfilePurple)
        StatusDot(color: .dsProfileGreen, glow: true)
        StatusDot(color: .dsProfileAmber, size: 8)
        StatusDot(color: .dsProfileRed, size: 6, glow: true)
    }
    .padding()
    .background(Color.dsBackground)
}
