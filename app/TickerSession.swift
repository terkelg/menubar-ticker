import Foundation
import Observation
import TickerCore

@Observable
@MainActor
final class TickerSession {
    enum Pause: Hashable {
        case popover
        case edit
    }

    private(set) var list: [String]
    private(set) var rate: Double
    private(set) var paused = false

    private let defaults: UserDefaults
    private var pauses = Set<Pause>()

    var text: String {
        TickerText.value(list)
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let list = Self.list(from: defaults)
        let rows = TickerText.rows(list)
        let raw = defaults.object(forKey: TickerText.rateKey) as? Double ?? TickerText.rateFallback
        let rate = TickerText.rate(raw)
        self.list = rows
        self.rate = rate

        if defaults.object(forKey: TickerText.key) as? [String] != rows {
            defaults.set(rows, forKey: TickerText.key)
        }

        if raw != rate {
            defaults.set(rate, forKey: TickerText.rateKey)
        }
    }

    func pause(_ kind: Pause) {
        pauses.insert(kind)
        sync()
    }

    func resume(_ kind: Pause) {
        pauses.remove(kind)
        sync()
    }

    func setList(_ list: [String]) {
        let rows = TickerText.rows(list)
        guard self.list != rows else { return }
        self.list = rows
        defaults.set(rows, forKey: TickerText.key)
    }

    func setRate(_ rate: Double) {
        let value = TickerText.rate(rate)
        guard self.rate != value else { return }
        self.rate = value
        defaults.set(value, forKey: TickerText.rateKey)
    }

    private func sync() {
        let paused = !pauses.isEmpty
        guard self.paused != paused else { return }
        self.paused = paused
    }

    private static func list(from defaults: UserDefaults) -> [String] {
        if let list = defaults.object(forKey: TickerText.key) as? [String] {
            return list
        }

        if let text = defaults.object(forKey: TickerText.key) as? String {
            return text.split(whereSeparator: \.isNewline).map(String.init)
        }

        return [""]
    }
}
