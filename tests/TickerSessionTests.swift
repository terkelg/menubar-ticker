import Foundation
import Testing
@testable import MenubarTicker
@testable import TickerCore

struct TickerSessionTests {
    @Test
    @MainActor
    func migratesStoredTextString() {
        let (name, defaults) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: name) }
        defaults.set("first\nsecond", forKey: TickerText.key)

        let session = TickerSession(defaults: defaults)

        #expect(session.list == ["first", "second"])
        #expect(defaults.object(forKey: TickerText.key) as? [String] == ["first", "second"])
    }

    @Test
    @MainActor
    func writesBackClampedStoredRate() {
        let (name, defaults) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: name) }
        defaults.set(1.8, forKey: TickerText.rateKey)

        let session = TickerSession(defaults: defaults)

        #expect(session.rate == TickerText.rateRange.upperBound)
        #expect(defaults.object(forKey: TickerText.rateKey) as? Double == TickerText.rateRange.upperBound)
    }

    private func makeDefaults() -> (String, UserDefaults) {
        let name = "TickerSessionTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return (name, defaults)
    }
}
