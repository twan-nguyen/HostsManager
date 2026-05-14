import SwiftUI

enum EnvKeyFormMode: Identifiable {
    case add
    case edit(EnvEntry)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let e): return "edit-\(e.id.uuidString)"
        }
    }
}

struct EnvKeyFormSheet: View {
    let mode: EnvKeyFormMode
    let onSave: (String, String, String) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var key: String = ""
    @State private var value: String = ""
    @State private var comment: String = ""
    @State private var errorMessage: String = ""

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private var title: String {
        isEditing ? "Sửa key" : "Thêm key mới"
    }

    var body: some View {
        DSSheetContainer(
            title: title,
            bodyContent: { formBody },
            footer: { footerButtons }
        )
        .frame(width: 460)
        .onAppear { populate() }
    }

    private var formBody: some View {
        VStack(alignment: .leading, spacing: DSSpacing.p3) {
            DSField("KEY", text: $key, prompt: "VITE_API_URL", monospaced: true, autocorrect: false)
            DSField("Value", text: $value, prompt: "https://api.example.com", monospaced: true)
            DSField("Ghi chú", text: $comment, prompt: "Tuỳ chọn")

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundStyle(Color.dsProfileRed)
                    .font(.dsCaption)
            }
        }
    }

    private var footerButtons: some View {
        HStack {
            Button("Hủy") { dismiss() }
                .keyboardShortcut(.escape)
            Spacer()
            Button(isEditing ? "Cập nhật" : "Thêm") { save() }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return)
        }
    }

    private func populate() {
        if case .edit(let entry) = mode {
            key = entry.key
            value = entry.value
            comment = entry.comment
        }
    }

    private func save() {
        errorMessage = ""
        let trimmedKey = key.trimmingCharacters(in: .whitespaces)
        guard !trimmedKey.isEmpty else {
            errorMessage = "Key không được để trống"
            return
        }
        guard isValidKey(trimmedKey) else {
            errorMessage = "Key chỉ chứa A-Z, 0-9, và _ (không bắt đầu bằng số)"
            return
        }
        onSave(trimmedKey, value, comment.trimmingCharacters(in: .whitespaces))
        dismiss()
    }

    private func isValidKey(_ s: String) -> Bool {
        guard let first = s.first, first.isLetter || first == "_" else { return false }
        return s.allSatisfy { $0.isLetter || $0.isNumber || $0 == "_" }
    }
}
