import SwiftUI

enum EnvProfileSheetMode: Identifiable {
    case save(repoId: UUID)
    case manage(repoId: UUID)

    var id: String {
        switch self {
        case .save(let id): return "save-\(id.uuidString)"
        case .manage(let id): return "manage-\(id.uuidString)"
        }
    }

    var repoId: UUID {
        switch self {
        case .save(let id), .manage(let id): return id
        }
    }
}

struct EnvProfileSheet: View {
    @Environment(EnvFileManager.self) private var envManager
    let mode: EnvProfileSheetMode
    @Environment(\.dismiss) private var dismiss

    @State private var newProfileName: String = ""
    @State private var errorMessage: String = ""
    @State private var renamingId: UUID?
    @State private var renameBuffer: String = ""

    private var repo: EnvRepo? {
        envManager.repos.first(where: { $0.id == mode.repoId })
    }

    var body: some View {
        switch mode {
        case .save:
            saveModeBody
        case .manage:
            manageModeBody
        }
    }

    // MARK: - Save mode

    private var saveModeBody: some View {
        DSSheetContainer(
            title: "Lưu state hiện tại thành profile",
            subtitle: "App sẽ chụp lại nội dung các file .env trong repo hiện tại.",
            bodyContent: {
                VStack(alignment: .leading, spacing: DSSpacing.p3) {
                    DSField(
                        "Tên profile",
                        text: $newProfileName,
                        prompt: "dev, staging, prod...",
                        autocorrect: false
                    )
                    .onSubmit { saveProfile() }

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundStyle(Color.dsProfileRed)
                            .font(.dsCaption)
                    }
                }
            },
            footer: {
                HStack {
                    Button("Hủy") { dismiss() }
                        .keyboardShortcut(.escape)
                    Spacer()
                    Button("Lưu") { saveProfile() }
                        .buttonStyle(.borderedProminent)
                        .keyboardShortcut(.return)
                        .disabled(newProfileName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        )
        .frame(width: 460)
    }

    private func saveProfile() {
        errorMessage = ""
        do {
            _ = try envManager.saveCurrentAsProfile(
                repoId: mode.repoId,
                profileName: newProfileName
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Manage mode

    private var manageModeBody: some View {
        DSSheetContainer(
            title: "Quản lý profiles",
            bodyContent: {
                Group {
                    if let repo = repo, !repo.profiles.isEmpty {
                        VStack(spacing: 0) {
                            ForEach(repo.profiles) { profile in
                                profileRow(profile)
                                if profile.id != repo.profiles.last?.id {
                                    Rectangle()
                                        .fill(Color.dsBorderTertiary)
                                        .frame(height: 1)
                                }
                            }
                        }
                        .frame(minHeight: 220, alignment: .top)
                    } else {
                        VStack {
                            Spacer()
                            Text("Chưa có profile nào")
                                .font(.dsBody)
                                .foregroundStyle(Color.dsTextSecondary)
                            Spacer()
                        }
                        .frame(minHeight: 220)
                        .frame(maxWidth: .infinity)
                    }
                }
            },
            footer: {
                Spacer()
                Button("Đóng") { dismiss() }
                    .keyboardShortcut(.escape)
            }
        )
        .frame(width: 540)
        .alert("Đổi tên profile", isPresented: Binding(
            get: { renamingId != nil },
            set: { if !$0 { renamingId = nil } }
        )) {
            TextField("Tên mới", text: $renameBuffer)
            Button("Đổi") { performRename() }
            Button("Hủy", role: .cancel) { renamingId = nil }
        }
    }

    @ViewBuilder
    private func profileRow(_ profile: EnvProfile) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(profile.name)
                    .font(.dsBody.weight(.medium))
                    .foregroundStyle(Color.dsTextPrimary)
                Text("\(profile.files.count) files · \(profile.capturedAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.dsCaption)
                    .foregroundStyle(Color.dsTextSecondary)
            }
            Spacer()
            Button {
                renamingId = profile.id
                renameBuffer = profile.name
            } label: {
                Image(systemName: "pencil")
                    .foregroundStyle(Color.dsTextSecondary)
            }
            .buttonStyle(.borderless)
            .help("Đổi tên")

            Button(role: .destructive) {
                envManager.deleteProfile(repoId: mode.repoId, profileId: profile.id)
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(Color.dsProfileRed)
            }
            .buttonStyle(.borderless)
            .help("Xoá")
        }
        .padding(.vertical, 8)
    }

    private func performRename() {
        guard let id = renamingId else { return }
        try? envManager.renameProfile(
            repoId: mode.repoId,
            profileId: id,
            newName: renameBuffer
        )
        renamingId = nil
        renameBuffer = ""
    }
}
