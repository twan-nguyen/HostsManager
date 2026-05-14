import SwiftUI

/// Tappable circular color swatch used in profile color pickers.
/// Selected state shows an outer ring around the fill.
struct ColorSwatch: View {
    let color: ProfileColor
    let isSelected: Bool
    let action: () -> Void

    private let dotSize: CGFloat = 22
    private let ringInset: CGFloat = 3

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .stroke(Color.ds(color), lineWidth: 1.5)
                    .frame(width: dotSize + ringInset * 2, height: dotSize + ringInset * 2)
                    .opacity(isSelected ? 1 : 0)

                Circle()
                    .fill(Color.ds(color))
                    .frame(width: dotSize, height: dotSize)
            }
            .frame(width: dotSize + ringInset * 2 + 2, height: dotSize + ringInset * 2 + 2)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .help(color.displayName)
    }
}

#Preview {
    HStack(spacing: 8) {
        ColorSwatch(color: .purple, isSelected: true, action: {})
        ColorSwatch(color: .green, isSelected: false, action: {})
        ColorSwatch(color: .amber, isSelected: false, action: {})
        ColorSwatch(color: .blue, isSelected: false, action: {})
        ColorSwatch(color: .red, isSelected: false, action: {})
    }
    .padding()
    .background(Color.dsBackground)
}
