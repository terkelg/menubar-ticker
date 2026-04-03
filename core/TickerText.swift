import Foundation

public enum TickerText {
    public static let key = "ticker-text"
    public static let rateKey = "ticker-rate"
    public static let dot = " • "
    public static let fallback = "I Will Not Make Any More Boring Art"
    public static let rateRange = 0.5 ... 1.5
    public static let rateFallback = 1.0

    public static func value(_ raw: String) -> String {
        let text = trim(raw)
        return text.isEmpty ? fallback : text
    }

    public static func loop(_ raw: String) -> String {
        "\(value(raw))\(dot)"
    }

    public static func value(_ raw: [String]) -> String {
        rows(raw).joined(separator: dot)
    }

    public static func loop(_ raw: [String]) -> String {
        "\(value(raw))\(dot)"
    }

    public static func rows(_ raw: [String]) -> [String] {
        let list = raw
            .map(trim)
            .filter { !$0.isEmpty }

        return list.isEmpty ? [fallback] : list
    }

    public static func rate(_ raw: Double) -> Double {
        min(max(raw, rateRange.lowerBound), rateRange.upperBound)
    }

    public static func rateText(_ raw: Double) -> String {
        let value = rate(raw)
        let text = value.formatted(.number.precision(.fractionLength(0 ... 2)))
        return "\(text)x"
    }

    private static func trim(_ raw: String) -> String {
        raw.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
