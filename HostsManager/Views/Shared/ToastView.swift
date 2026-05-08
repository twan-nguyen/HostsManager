import SwiftUI

/// Floating notification pill styled for the dark UI: muted dark surface with
/// a small colored icon. Replaces the saturated tinted-glass look that fought
/// the rest of the dark palette.
struct ToastView: View {
    let toast: ToastMessage

    private var accentColor: Color {
        switch toast.type {
        case .success: return .dsResolvedGreen   // #5dcaa5 — DS green
        case .error:   return .dsProfileRed      // #e24b4a
        case .info:    return Color(hex: "#378ADD")
        }
    }

    private var icon: String {
        switch toast.type {
        case .success: return "checkmark.circle.fill"
        case .error:   return "xmark.circle.fill"
        case .info:    return "info.circle.fill"
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(accentColor)
                .font(.system(size: 14, weight: .semibold))
            Text(toast.message)
                .font(.system(size: 12.5, weight: .medium))
                .foregroundStyle(Color.dsTextPrimary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "#1f1f21"))
                RoundedRectangle(cornerRadius: 10)
                    .fill(accentColor.opacity(0.06))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(accentColor.opacity(0.30), lineWidth: 0.8)
        )
        .shadow(color: .black.opacity(0.35), radius: 14, y: 6)
    }
}
