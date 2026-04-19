import SwiftUI

struct SearchableWithFocus: ViewModifier {
    @Binding var searchText: String
    @Binding var isPresented: Bool

    func body(content: Content) -> some View {
        if #available(macOS 14.0, *) {
            content
                .searchable(
                    text: $searchText,
                    isPresented: $isPresented,
                    placement: .toolbar,
                    prompt: "Tìm kiếm hostname, IP..."
                )
        } else {
            content
                .searchable(text: $searchText, placement: .toolbar, prompt: "Tìm kiếm hostname, IP...")
        }
    }
}

struct GlassBackgroundModifier: ViewModifier {
    let cornerRadius: CGFloat
    var tintColor: Color = .clear

    func body(content: Content) -> some View {
        if #available(macOS 26, *) {
            content
                .glassEffect(
                    tintColor == .clear ? .regular : .regular.tint(tintColor),
                    in: .rect(cornerRadius: cornerRadius)
                )
        } else {
            content
                .background(.ultraThinMaterial, in: .rect(cornerRadius: cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(tintColor.opacity(0.3), lineWidth: tintColor == .clear ? 0 : 1)
                )
        }
    }
}

struct PulseEffectModifier: ViewModifier {
    let isActive: Bool

    func body(content: Content) -> some View {
        if #available(macOS 14.0, *) {
            content.symbolEffect(.pulse, isActive: isActive)
        } else {
            content
        }
    }
}

struct NumericTransitionModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 14.0, *) {
            content.contentTransition(.numericText())
        } else {
            content
        }
    }
}
