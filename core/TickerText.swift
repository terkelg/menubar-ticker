import Foundation

public enum TickerText {
    public static let key = "ticker-text"
    public static let rateKey = "ticker-rate"
    public static let dot = " • "
    public static let fallback = "A macOS menu bar ticker that loops forever."
    public static let rateRange = 0.5 ... 2.0
    public static let rateFallback = 1.0

    public static func value(_ raw: String) -> String {
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? fallback : text
    }

    public static func loop(_ raw: String) -> String {
        "\(value(raw))\(dot)"
    }

    public static func rate(_ raw: Double) -> Double {
        min(max(raw, rateRange.lowerBound), rateRange.upperBound)
    }

    public static func rateText(_ raw: Double) -> String {
        let value = rate(raw)
        let text = value.formatted(.number.precision(.fractionLength(0 ... 2)))
        return "\(text)x"
    }
}
