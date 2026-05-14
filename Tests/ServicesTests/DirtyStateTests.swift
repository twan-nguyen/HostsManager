import Testing
import Foundation
@testable import Hosven

@Suite("Dirty state derives from content, not setter calls")
@MainActor
struct DirtyStateTests {
    private func makeManager() -> HostsFileManager {
        HostsFileManager(profileStore: MockProfileStore(), autoLoad: false)
    }

    @Test("Fresh manager (autoLoad=false) is clean")
    func freshIsClean() {
        let m = makeManager()
        #expect(!m.hasUnsavedChanges)
    }

    @Test("Adding an entry flips dirty true")
    func addDirties() {
        let m = makeManager()
        m.addEntry(ip: "10.0.0.1", hostname: "foo", comment: "")
        #expect(m.hasUnsavedChanges)
    }

    @Test("Mutate-then-revert clears dirty automatically")
    func revertClears() {
        let m = makeManager()
        m.entries = [HostEntry(ip: "10.0.0.1", hostname: "foo")]
        m.captureClean()
        #expect(!m.hasUnsavedChanges)

        m.toggleEntry(id: m.entries[0].id)
        #expect(m.hasUnsavedChanges)

        // Revert by toggling back.
        m.toggleEntry(id: m.entries[0].id)
        #expect(!m.hasUnsavedChanges, "Toggling back to original state must clear dirty")
    }

    @Test("Undo back to load state clears dirty")
    func undoClears() {
        let m = makeManager()
        m.entries = [HostEntry(ip: "10.0.0.1", hostname: "foo")]
        m.captureClean()

        m.addEntry(ip: "10.0.0.2", hostname: "bar", comment: "")
        #expect(m.hasUnsavedChanges)

        m.undo()
        #expect(!m.hasUnsavedChanges, "Undo to pristine state must clear dirty")
    }

    @Test("captureClean snapshots current state as new pristine")
    func captureCleanResets() {
        let m = makeManager()
        m.addEntry(ip: "10.0.0.1", hostname: "foo", comment: "")
        #expect(m.hasUnsavedChanges)

        m.captureClean()
        #expect(!m.hasUnsavedChanges)
    }

    @Test("markRawTextDirty forces dirty even when entries match pristine")
    func rawTextOverride() {
        let m = makeManager()
        m.captureClean()
        #expect(!m.hasUnsavedChanges)

        m.markRawTextDirty()
        #expect(m.hasUnsavedChanges)

        m.captureClean()
        #expect(!m.hasUnsavedChanges)
    }
}

@Suite("EnvFile dirty state")
struct EnvFileDirtyTests {
    @Test("Fresh EnvFile is clean")
    func freshIsClean() {
        let f = EnvFile(relativePath: ".env", entries: [
            EnvEntry(key: "FOO", value: "1")
        ])
        #expect(!f.hasUnsavedChanges)
    }

    @Test("Mutating entries flips dirty")
    func mutateDirties() {
        var f = EnvFile(relativePath: ".env", entries: [
            EnvEntry(key: "FOO", value: "1")
        ])
        f.entries[0].value = "2"
        #expect(f.hasUnsavedChanges)
    }

    @Test("Revert to pristine clears dirty")
    func revertClears() {
        let original = [EnvEntry(key: "FOO", value: "1")]
        var f = EnvFile(relativePath: ".env", entries: original)
        f.entries[0].value = "2"
        #expect(f.hasUnsavedChanges)

        f.entries = original
        #expect(!f.hasUnsavedChanges)
    }

    @Test("rawTextDirty forces dirty")
    func rawTextOverride() {
        var f = EnvFile(relativePath: ".env", entries: [])
        #expect(!f.hasUnsavedChanges)
        f.rawTextDirty = true
        #expect(f.hasUnsavedChanges)
    }
}
