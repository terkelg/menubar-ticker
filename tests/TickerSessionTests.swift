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

struct PopoverEventTests {
    @Test
    func keepsClicksInsidePopover() {
        let frame = CGRect(x: 10, y: 20, width: 120, height: 80)

        #expect(PopoverEvent.shouldClose(at: CGPoint(x: 50, y: 50), in: frame) == false)
    }

    @Test
    func closesClicksOutsidePopover() {
        let frame = CGRect(x: 10, y: 20, width: 120, height: 80)

        #expect(PopoverEvent.shouldClose(at: CGPoint(x: 5, y: 50), in: frame))
    }
}
