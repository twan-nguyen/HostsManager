import Testing
import Foundation
@testable import Devly

@Suite("HostsFileManager undo/redo")
@MainActor
struct UndoRedoTests {
    /// Build manager with autoLoad=false so we control state without /etc/hosts.
    private func makeManager() -> HostsFileManager {
        HostsFileManager(profileStore: MockProfileStore(), autoLoad: false)
    }

    private func seed(_ m: HostsFileManager, count: Int) {
        for i in 0..<count {
            m.entries.append(HostEntry(ip: "10.0.0.\(i)", hostname: "host\(i)"))
        }
        m.captureClean()
    }

    @Test("Initial state has empty undo/redo stacks")
    func initialState() {
        let m = makeManager()
        #expect(!m.canUndo)
        #expect(!m.canRedo)
    }

    @Test("Toggle entry pushes undo, undo restores")
    func undoToggle() {
        let m = makeManager()
        seed(m, count: 1)
        let id = m.entries[0].id
        let before = m.entries[0].isEnabled

        m.toggleEntry(id: id)
        #expect(m.entries[0].isEnabled != before)
        #expect(m.canUndo)
        #expect(!m.canRedo)

        m.undo()
        #expect(m.entries[0].isEnabled == before)
        #expect(!m.canUndo)
        #expect(m.canRedo)
    }

    @Test("Add entry then undo removes it")
    func undoAdd() {
        let m = makeManager()
        seed(m, count: 1)
        let initialCount = m.entries.count

        m.addEntry(ip: "1.1.1.1", hostname: "new.test", comment: "")
        #expect(m.entries.count == initialCount + 1)

        m.undo()
        #expect(m.entries.count == initialCount)
    }

    @Test("Delete entry then undo restores it")
    func undoDelete() {
        let m = makeManager()
        seed(m, count: 2)
        let removedId = m.entries[1].id
        let removedHostname = m.entries[1].hostname

        m.deleteEntry(id: removedId)
        #expect(!m.entries.contains { $0.id == removedId })

        m.undo()
        #expect(m.entries.contains { $0.hostname == removedHostname })
    }

    @Test("Redo re-applies an undone change")
    func redoRoundTrip() {
        let m = makeManager()
        seed(m, count: 1)
        let id = m.entries[0].id

        m.toggleEntry(id: id)
        let toggled = m.entries[0].isEnabled
        m.undo()
        m.redo()
        #expect(m.entries[0].isEnabled == toggled)
        #expect(!m.canRedo)
    }

    @Test("New mutation clears redo stack")
    func mutationClearsRedo() {
        let m = makeManager()
        seed(m, count: 1)
        let id = m.entries[0].id

        m.toggleEntry(id: id)
        m.undo()
        #expect(m.canRedo)

        m.addEntry(ip: "9.9.9.9", hostname: "x.test", comment: "")
        #expect(!m.canRedo, "new mutation should clear redo stack")
    }

    @Test("Stack capped at 50 entries — oldest dropped")
    func stackCappedAt50() {
        let m = makeManager()
        seed(m, count: 1)
        let id = m.entries[0].id

        for _ in 0..<60 {
            m.toggleEntry(id: id)
        }
        // Undo all the way down — should hit empty stack after at most 50
        var undoCount = 0
        while m.canUndo, undoCount < 100 {
            m.undo()
            undoCount += 1
        }
        #expect(undoCount <= 50, "undo stack should be capped at 50 (got \(undoCount))")
    }

    @Test("Coalesces consecutive identical snapshots")
    func coalescesIdenticalSnapshots() {
        let m = makeManager()
        seed(m, count: 1)
        let id = m.entries[0].id

        m.updateEntry(id: id, ip: "10.0.0.0", hostname: "host0", comment: "")
        // Same exact values — should NOT push a duplicate snapshot
        m.updateEntry(id: id, ip: "10.0.0.0", hostname: "host0", comment: "")

        var undoCount = 0
        while m.canUndo {
            m.undo()
            undoCount += 1
        }
        #expect(undoCount == 1, "expected single snapshot, got \(undoCount)")
    }
}
