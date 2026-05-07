import Testing
import Foundation
@testable import HostsManager

@Suite("HostsFileManager parser")
@MainActor
struct HostsParserTests {
    /// Build a fresh manager and seed it with content (skip /etc/hosts read).
    private func makeManager(seed: String) -> HostsFileManager {
        let m = HostsFileManager()
        m.parseHostsContent(seed)
        return m
    }

    private static let fixture = """
    # Sample /etc/hosts fixture for parser round-trip tests.
    ##
    # Hostfile

    127.0.0.1\tlocalhost
    ::1\tlocalhost

    ## [tag:Release]
    127.0.0.1\tapi.dev.example.com # local API
    127.0.0.1\tweb.dev.example.com
    ## [/tag:Release]

    ## [tag:Production]
    10.0.0.5\tapi.prod.example.com
    # 10.0.0.6\tapi.staging.example.com # disabled staging
    ## [/tag:Production]

    """

    private func loadFixture() -> String { Self.fixture }

    @Test("Parses tag markers and groups entries by tag")
    func parsesTags() {
        let m = makeManager(seed: loadFixture())

        let tagNames = m.tags.map(\.name).sorted()
        #expect(tagNames == ["Production", "Release"])

        let releaseHosts = m.entries.filter { $0.tag == "Release" }.map(\.hostname).sorted()
        #expect(releaseHosts == ["api.dev.example.com", "web.dev.example.com"])
    }

    @Test("Treats commented IP+hostname as disabled entry, not pure comment")
    func parsesDisabledEntries() {
        let m = makeManager(seed: loadFixture())

        let staging = m.entries.first(where: { $0.hostname == "api.staging.example.com" })
        #expect(staging != nil)
        #expect(staging?.isEnabled == false)
        #expect(staging?.ip == "10.0.0.6")
        #expect(staging?.tag == "Production")
    }

    @Test("Round-trip parse → generate preserves tag grouping and entry count")
    func roundTrip() {
        let m1 = makeManager(seed: loadFixture())
        let regenerated = m1.generateHostsContent()
        let m2 = makeManager(seed: regenerated)

        #expect(m1.entries.count == m2.entries.count)
        #expect(m1.tags.map(\.name) == m2.tags.map(\.name))

        for (a, b) in zip(m1.entries, m2.entries) {
            #expect(a.ip == b.ip)
            #expect(a.hostname == b.hostname)
            #expect(a.isEnabled == b.isEnabled)
            #expect(a.tag == b.tag)
        }
    }

    @Test("Localhost entries parsed as enabled with no tag")
    func parsesLocalhost() {
        let m = makeManager(seed: loadFixture())

        let localhost = m.entries.filter { $0.hostname == "localhost" }
        #expect(localhost.count == 2, "Both 127.0.0.1 and ::1 entries expected")
        #expect(localhost.allSatisfy { $0.isEnabled })
        #expect(localhost.allSatisfy { $0.tag == nil })
    }

    @Test("Empty content yields zero entries")
    func emptyContent() {
        let m = makeManager(seed: "")
        #expect(m.entries.isEmpty)
        #expect(m.tags.isEmpty)
    }

    @Test("Disabled-line branch validates IP, rejecting non-IP first token")
    func disabledLineRequiresValidIP() {
        // Disabled-entry branch (#-prefixed) requires valid IP — non-IP first token treated as pure comment.
        let m = makeManager(seed: "# not a valid host line\n# 127.0.0.1 valid.example.com")
        #expect(m.entries.count == 1)
        #expect(m.entries.first?.isEnabled == false)
        #expect(m.entries.first?.hostname == "valid.example.com")
    }

    @Test("entryCount matches filter buckets")
    func entryCounts() {
        let m = makeManager(seed: loadFixture())

        let total = m.entryCount(for: .all)
        let enabled = m.entryCount(for: .enabled)
        let disabled = m.entryCount(for: .disabled)
        #expect(total == enabled + disabled)
        #expect(disabled >= 1, "fixture has at least one disabled entry")
    }
}

