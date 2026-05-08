import SwiftUI

/// 28-pt footer at window bottom: file context + pending changes + Apply/Undo actions.
/// Reference: docs/mockup-reference.md → "StatusBar".
struct StatusBarView: View {
    let activeTab: AppTab
    let pendingChanges: Int
    let isApplying: Bool
    var sudoOK: Bool = false
    var canUndo: Bool = false
    var canRedo: Bool = false
    var onUndo: () -> Void = {}
    var onRedo: () -> Void = {}
    var onApply: () -> Void = {}

    private var filePathText: String {
        switch activeTab {
        case .hosts: return "/etc/hosts"
        case .env:   return ".env"
        }
    }

    var body: some View {
        HStack(spacing: DSSpacing.p3) {
            HStack(spacing: 4) {
                Image(systemName: activeTab == .hosts ? "doc.text" : "doc.plaintext")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.dsTextTertiary)
                Text(filePathText)
                    .font(.dsMonoSmall)
                    .foregroundStyle(Color.dsTextSecondary)
            }

            if pendingChanges > 0 {
                HStack(spacing: DSSpacing.p3) {
                    Text("·")
                        .foregroundStyle(Color.dsTextTertiary)
                    pendingHint
                }
                .transition(.opacity.combined(with: .move(edge: .leading)))
            }

            Spacer()

            undoButton
            redoButton
            applyButton
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 4)
        .frame(height: 28)
        .background(Color.dsBackgroundSidebar)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.dsBorderTertiary)
                .frame(height: 0.5)
        }
        .animation(.dsSmooth, value: pendingChanges)
        .animation(.dsSnappy, value: isApplying)
        .animation(.dsSnappy, value: canUndo)
        .animation(.dsSnappy, value: canRedo)
    }

    // MARK: - Subviews

    /// Pending changes hint — for hosts shows sudo requirement, env shows file count.
    @ViewBuilder
    private var pendingHint: some View {
        if activeTab == .hosts {
            HStack(spacing: 4) {
                Text("\(pendingChanges) thay đổi")
                    .font(.system(size: 10.5))
                    .foregroundStyle(Color.dsTextSecondary)
                Text("·")
                    .foregroundStyle(Color.dsTextTertiary)
                Image(systemName: sudoOK ? "checkmark.shield.fill" : "shield")
                    .font(.system(size: 10))
                    .foregroundStyle(sudoOK ? Color.dsResolvedGreen : Color.dsTextTertiary)
                Text(sudoOK ? "sudo OK" : "cần sudo")
                    .font(.system(size: 10.5))
                    .foregroundStyle(Color.dsTextSecondary)
            }
        } else {
            Text("\(pendingChanges) file thay đổi")
                .font(.system(size: 10.5))
                .foregroundStyle(Color.dsTextSecondary)
        }
    }

    private var undoButton: some View {
        Button(action: onUndo) {
            Image(systemName: "arrow.uturn.backward")
                .font(.system(size: 10.5))
                .foregroundStyle(Color.dsTextSecondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.sm)
                        .strokeBorder(Color.dsBorderSecondary, lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
        .disabled(!canUndo)
        .opacity(canUndo ? 1 : 0.4)
        .help("Hoàn tác (⌘Z)")
    }

    private var redoButton: some View {
        Button(action: onRedo) {
            Image(systemName: "arrow.uturn.forward")
                .font(.system(size: 10.5))
                .foregroundStyle(Color.dsTextSecondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.sm)
                        .strokeBorder(Color.dsBorderSecondary, lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
        .disabled(!canRedo)
        .opacity(canRedo ? 1 : 0.4)
        .help("Làm lại (⌘⇧Z)")
    }

    private var applyButton: some View {
        Button(action: onApply) {
            HStack(spacing: 4) {
                Group {
                    if isApplying {
                        ProgressView().controlSize(.mini)
                    } else {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .semibold))
                    }
                }
                .transition(.opacity.combined(with: .scale))
                Text(isApplying ? "Đang lưu" : "Áp dụng")
                    .font(.system(size: 10, weight: .medium))
                    .contentTransition(.numericText())
                Text("⌘S")
                    .font(.dsMonoTiny)
                    .opacity(0.85)
            }
            .padding(.horizontal, DSSpacing.p3)
            .padding(.vertical, 3)
            .foregroundStyle(.white)
            .background(applyButtonBackground)
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.sm)
                    .strokeBorder(Color(hex: "#78b4ff").opacity(0.4), lineWidth: 0.5)
            )
            .scaleEffect(pendingChanges == 0 ? 0.96 : 1)
        }
        .buttonStyle(.plain)
        .keyboardShortcut("s", modifiers: .command)
        .disabled(pendingChanges == 0 || isApplying)
        .opacity(pendingChanges == 0 ? 0.5 : 1)
    }

    private var applyButtonBackground: some View {
        RoundedRectangle(cornerRadius: DSRadius.sm)
            .fill(LinearGradient(
                colors: [Color(hex: "#378ADD"), Color(hex: "#185FA5")],
                startPoint: .top,
                endPoint: .bottom
            ))
    }
}

#Preview("Variants") {
    VStack(spacing: 8) {
        StatusBarView(activeTab: .hosts, pendingChanges: 0, isApplying: false)
        StatusBarView(activeTab: .hosts, pendingChanges: 3, isApplying: false)
        StatusBarView(activeTab: .env, pendingChanges: 1, isApplying: true)
    }
    .frame(width: 980)
    .background(Color.dsBackground)
}
