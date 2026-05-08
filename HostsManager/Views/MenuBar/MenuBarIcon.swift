import SwiftUI

/// Menu bar status item icon — three cascading profile cards in monochrome,
/// mirroring the AppIcon design at template-icon size. Renders crisp at 18pt.
/// Color follows `foregroundStyle` so the macOS menu bar can tint it.
struct MenuBarIcon: View {
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            let cardW = w * 0.78
            let cardH = h * 0.20
            let dot = cardH * 0.62
            let gap = h * 0.10
            let totalH = cardH * 3 + gap * 2
            let startY = (h - totalH) / 2.0
            let offsets: [CGFloat] = [w * 0.10, 0.0, -w * 0.08]

            ZStack(alignment: .topLeading) {
                ForEach(0..<3, id: \.self) { i in
                    let y = startY + CGFloat(i) * (cardH + gap)
                    let x = (w - cardW) / 2.0 + offsets[i]

                    // Card with the leading dot punched out so the icon reads at 18pt.
                    Capsule()
                        .fill(style: FillStyle(eoFill: true))
                        .frame(width: cardW, height: cardH)
                        .reverseMask(alignment: .leading) {
                            Circle()
                                .frame(width: dot, height: dot)
                                .padding(.leading, (cardH - dot) / 2.0)
                        }
                        .offset(x: x, y: y)
                }
            }
            .frame(width: w, height: h)
        }
        .frame(width: 18, height: 18)
    }
}

private extension View {
    /// Cuts the masked shape OUT of the view (inverse of `.mask`).
    @ViewBuilder
    func reverseMask<Mask: View>(
        alignment: Alignment = .center,
        @ViewBuilder _ mask: () -> Mask
    ) -> some View {
        self.mask {
            Rectangle()
                .overlay(alignment: alignment) {
                    mask().blendMode(.destinationOut)
                }
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        MenuBarIcon().foregroundStyle(.black)
        MenuBarIcon().foregroundStyle(.white)
    }
    .padding(20)
    .background(Color.gray)
}
