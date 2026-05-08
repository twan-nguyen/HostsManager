import SwiftUI

struct ImportSheet: View {
    let hostsManager: HostsFileManager
    @Environment(\.dismiss) private var dismiss
    @State private var importText = ""

    var body: some View {
        DSSheetContainer(
            title: "Import Entries",
            subtitle: "Paste nội dung file hosts vào đây. Chỉ các entry chưa tồn tại mới được thêm.",
            bodyContent: {
                VStack(alignment: .leading, spacing: DSSpacing.p2) {
                    Text("Nội dung")
                        .font(.dsLabel)
                        .foregroundStyle(Color.dsTextSecondary)

                    TextEditor(text: $importText)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(Color.dsTextPrimary)
                        .scrollContentBackground(.hidden)
                        .padding(8)
                        .frame(minHeight: 220)
                        .background(Color.white.opacity(0.04))
                        .overlay(
                            RoundedRectangle(cornerRadius: DSRadius.md)
                                .stroke(Color.dsBorderPrimary, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
                }
            },
            footer: {
                HStack {
                    Button("Hủy") { dismiss() }
                        .keyboardShortcut(.escape)
                    Spacer()
                    Button("Import") {
                        hostsManager.importEntries(from: importText)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(importText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        )
        .frame(width: 540)
    }
}
