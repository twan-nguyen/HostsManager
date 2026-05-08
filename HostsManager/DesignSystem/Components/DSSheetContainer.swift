import SwiftUI

/// Themed shell for modal sheets so popups stay consistent with the dark
/// design system. Provides a header (title + optional subtitle), a body slot,
/// and a footer slot for action buttons.
///
/// Reference: docs/mockup-reference.md.
struct DSSheetContainer<Body: View, Footer: View>: View {
    let title: String
    var subtitle: String? = nil
    @ViewBuilder let bodyContent: () -> Body
    @ViewBuilder let footer: () -> Footer

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            divider
            bodyContent()
                .padding(.horizontal, DSSpacing.p5)
                .padding(.vertical, DSSpacing.p4)
            divider
            HStack(spacing: DSSpacing.p2) { footer() }
                .padding(.horizontal, DSSpacing.p5)
                .padding(.vertical, DSSpacing.p3)
        }
        .background(Color.dsBackground)
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.dsTitle)
                .foregroundStyle(Color.dsTextPrimary)
            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.dsCaption)
                    .foregroundStyle(Color.dsTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, DSSpacing.p5)
        .padding(.top, DSSpacing.p5)
        .padding(.bottom, DSSpacing.p4)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.dsBorderTertiary)
            .frame(height: 1)
    }
}
