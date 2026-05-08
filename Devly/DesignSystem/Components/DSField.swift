import SwiftUI

/// Labeled text field block aligned with the dark design system.
/// Renders a tiny uppercase label, themed input box, and optional helper row.
struct DSField<Helper: View>: View {
    let label: String
    @Binding var text: String
    var prompt: String? = nil
    var monospaced: Bool = false
    var autocorrect: Bool = true
    @ViewBuilder var helper: () -> Helper

    init(
        _ label: String,
        text: Binding<String>,
        prompt: String? = nil,
        monospaced: Bool = false,
        autocorrect: Bool = true,
        @ViewBuilder helper: @escaping () -> Helper = { EmptyView() }
    ) {
        self.label = label
        self._text = text
        self.prompt = prompt
        self.monospaced = monospaced
        self.autocorrect = autocorrect
        self.helper = helper
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.dsLabel)
                .foregroundStyle(Color.dsTextSecondary)

            TextField(
                "",
                text: $text,
                prompt: prompt.map { Text($0).foregroundStyle(Color.dsTextTertiary) }
            )
            .textFieldStyle(.plain)
            .font(monospaced ? .system(size: 12, design: .monospaced) : .dsBody)
            .foregroundStyle(Color.dsTextPrimary)
            .autocorrectionDisabled(!autocorrect)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.04))
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.md)
                    .stroke(Color.dsBorderPrimary, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))

            helper()
        }
    }
}
