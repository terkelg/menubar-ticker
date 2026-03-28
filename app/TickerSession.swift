import Combine
import Foundation
import TickerCore

@MainActor
final class TickerSession: ObservableObject {
    enum Pause: Hashable {
        case popover
        case edit
    }

    @Published private(set) var text: String
    @Published private(set) var rate: Double
    @Published private(set) var paused = false

    private let defaults: UserDefaults
    private var pauses = Set<Pause>()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let text = defaults.object(forKey: TickerText.key) as? String ?? TickerText.fallback
        let raw = defaults.object(forKey: TickerText.rateKey) as? Double ?? TickerText.rateFallback
        self.text = text
        self.rate = TickerText.rate(raw)
    }

    func pause(_ kind: Pause) {
        pauses.insert(kind)
        sync()
    }

    func resume(_ kind: Pause) {
        pauses.remove(kind)
        sync()
    }

    func setText(_ text: String) {
        self.text = text
        defaults.set(text, forKey: TickerText.key)
    }

    func setRate(_ rate: Double) {
        let value = TickerText.rate(rate)
        self.rate = value
        defaults.set(value, forKey: TickerText.rateKey)
    }

    private func sync() {
        paused = !pauses.isEmpty
    }
}
