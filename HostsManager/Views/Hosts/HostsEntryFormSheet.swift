import SwiftUI

enum EntryFormMode: Identifiable {
    case add
    case edit(HostEntry)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let entry): return entry.id.uuidString
        }
    }
}

struct EntryFormSheet: View {
    let hostsManager: HostsFileManager
    let mode: EntryFormMode
    @Environment(\.dismiss) private var dismiss

    @State private var ip = ""
    @State private var hostname = ""
    @State private var comment = ""
    @State private var selectedTag: String = ""
    @State private var errorMessage = ""

    var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var title: String {
        isEditing ? "Sửa entry" : "Thêm entry mới"
    }

    var body: some View {
        DSSheetContainer(
            title: title,
            bodyContent: { formBody },
            footer: { footerButtons }
        )
        .frame(width: 460)
        .onAppear {
            if case .edit(let entry) = mode {
                ip = entry.ip
                hostname = entry.hostname
                comment = entry.comment
                selectedTag = entry.tag ?? ""
            }
        }
    }

    private var formBody: some View {
        VStack(alignment: .leading, spacing: DSSpacing.p3) {
            DSField("IP Address", text: $ip, prompt: "127.0.0.1", monospaced: true) {
                HStack(spacing: 6) {
                    Text("Chọn nhanh")
                        .font(.dsCaption)
                        .foregroundStyle(Color.dsTextTertiary)
                    QuickIPButton(label: "127.0.0.1", ip: $ip)
                    QuickIPButton(label: "0.0.0.0", ip: $ip)
                    QuickIPButton(label: "::1", ip: $ip)
                }
            }

            DSField("Hostname", text: $hostname, prompt: "example.com", monospaced: true)

            DSField("Ghi chú", text: $comment, prompt: "Tuỳ chọn")

            if !hostsManager.tags.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Tag")
                        .font(.dsLabel)
                        .foregroundStyle(Color.dsTextSecondary)
                    Picker("", selection: $selectedTag) {
                        Text("Không có tag").tag("")
                        ForEach(hostsManager.tags) { tag in
                            Text(tag.name).tag(tag.name)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                }
            }

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

    private func save() {
        errorMessage = ""

        guard !ip.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "IP không được để trống"
            return
        }
        guard !hostname.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Hostname không được để trống"
            return
        }

        let trimmedHostname = hostname.trimmingCharacters(in: .whitespaces)
        let trimmedIP = ip.trimmingCharacters(in: .whitespaces)
        let tagValue = selectedTag.isEmpty ? nil : selectedTag

        if case .add = mode {
            if hostsManager.hostnameExists(trimmedHostname) {
                errorMessage = "Hostname \"\(trimmedHostname)\" đã tồn tại"
                return
            }
            hostsManager.addEntry(
                ip: trimmedIP,
                hostname: trimmedHostname,
                comment: comment.trimmingCharacters(in: .whitespaces),
                tag: tagValue
            )
        } else if case .edit(let entry) = mode {
            hostsManager.updateEntry(
                id: entry.id,
                ip: trimmedIP,
                hostname: trimmedHostname,
                comment: comment.trimmingCharacters(in: .whitespaces),
                tag: tagValue
            )
        }

        dismiss()
    }
}

struct QuickIPButton: View {
    let label: String
    @Binding var ip: String

    var body: some View {
        Button(label) { ip = label }
            .buttonStyle(.plain)
            .font(.system(size: 10, design: .monospaced))
            .foregroundStyle(Color.dsTextSecondary)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.sm)
                    .stroke(Color.dsBorderSecondary, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
    }
}
