import Testing
import Foundation
@testable import Devly

@Suite("EnvFileManager edit + apply round-trip")
@MainActor
struct EnvEditApplyFlowTests {
    /// Creates a manager with a real temp repo + .env file so writeContent can run.
    private func makeFixture() throws -> (manager: EnvFileManager, repo: EnvRepo, file: EnvFile, dir: URL) {
        let dir = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("env-test-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let envPath = dir.appendingPathComponent(".env")
        try "FOO=1\nBAR=2\n".write(to: envPath, atomically: true, encoding: .utf8)

        let storage = dir.appendingPathComponent("env-config.json")
        let m = EnvFileManager(storageURL: storage)
        try m.addRepo(at: dir)
        guard let repo = m.repos.first else {
            throw EnvError.repoNotFound
        }
        let file = try m.loadFile(repoId: repo.id, relativePath: ".env")
        m.setLoadedFile(repoId: repo.id, file: file)
        m.selectedFilePath = ".env"
        return (m, repo, file, dir)
    }

    @Test("Loaded file is clean (entries == pristineEntries)")
    func loadedIsClean() throws {
        let f = try makeFixture()
        defer { try? FileManager.default.removeItem(at: f.dir) }
        guard let cached = f.manager.loadedFile(repoId: f.repo.id, relativePath: ".env") else {
            Issue.record("No cached file")
            return
        }
        #expect(!cached.hasUnsavedChanges)
    }

    @Test("Edit entry → cached file becomes dirty")
    func editFlipsDirty() throws {
        let f = try makeFixture()
        defer { try? FileManager.default.removeItem(at: f.dir) }
        let entryId = f.file.entries[0].id

        f.manager.updateEntry(
            repoId: f.repo.id,
            fileId: f.file.id,
            entryId: entryId,
            key: "FOO",
            value: "999",
            comment: ""
        )

        guard let cached = f.manager.loadedFile(repoId: f.repo.id, relativePath: ".env") else {
            Issue.record("No cached file after edit")
            return
        }
        #expect(cached.entries.first?.value == "999")
        #expect(cached.hasUnsavedChanges, "After updateEntry the file must be dirty")
    }

    @Test("Apply writes to disk + clears dirty")
    func applyClears() throws {
        let f = try makeFixture()
        defer { try? FileManager.default.removeItem(at: f.dir) }
        let entryId = f.file.entries[0].id

        f.manager.updateEntry(
            repoId: f.repo.id,
            fileId: f.file.id,
            entryId: entryId,
            key: "FOO",
            value: "999",
            comment: ""
        )
        f.manager.applyCurrentSelection()

        guard let cached = f.manager.loadedFile(repoId: f.repo.id, relativePath: ".env") else {
            Issue.record("No cached file after apply")
            return
        }
        #expect(!cached.hasUnsavedChanges, "Apply must clear dirty")

        // Re-read disk to confirm write landed.
        let disk = try String(contentsOf: f.dir.appendingPathComponent(".env"), encoding: .utf8)
        #expect(disk.contains("FOO=999"))
    }

    @Test("addEntry, deleteEntry, toggleEntry all dirty the file")
    func crudDirties() throws {
        let f = try makeFixture()
        defer { try? FileManager.default.removeItem(at: f.dir) }

        // Add
        f.manager.addEntry(repoId: f.repo.id, fileId: f.file.id, key: "BAZ", value: "3", comment: "")
        #expect(f.manager.loadedFile(repoId: f.repo.id, relativePath: ".env")?.hasUnsavedChanges == true)
        f.manager.applyCurrentSelection()

        // Toggle
        if let id = f.manager.loadedFile(repoId: f.repo.id, relativePath: ".env")?.entries.first?.id {
            f.manager.toggleEntry(repoId: f.repo.id, fileId: f.file.id, entryId: id)
            #expect(f.manager.loadedFile(repoId: f.repo.id, relativePath: ".env")?.hasUnsavedChanges == true)
            f.manager.applyCurrentSelection()
        }

        // Delete
        if let id = f.manager.loadedFile(repoId: f.repo.id, relativePath: ".env")?.entries.last?.id {
            f.manager.deleteEntry(repoId: f.repo.id, fileId: f.file.id, entryId: id)
            #expect(f.manager.loadedFile(repoId: f.repo.id, relativePath: ".env")?.hasUnsavedChanges == true)
        }
    }
}
