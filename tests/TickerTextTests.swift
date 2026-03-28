import Testing
@testable import TickerCore

struct TickerTextTests {
    @Test
    func trimsText() {
        #expect(TickerText.value("  hello world  ") == "hello world")
    }

    @Test
    func fallsBackWhenBlank() {
        #expect(TickerText.value(" \n ") == TickerText.fallback)
    }

    @Test
    func appendsDot() {
        #expect(TickerText.loop("hello world") == "hello world • ")
    }

    @Test
    func appendsDotToFallback() {
        #expect(TickerText.loop(" \n ") == "\(TickerText.fallback)\(TickerText.dot)")
    }

    @Test
    func fallsBackWhenRateIsUnknown() {
        #expect(TickerText.rate(9) == TickerText.rateRange.upperBound)
    }

    @Test
    func clampsRateLow() {
        #expect(TickerText.rate(0.1) == TickerText.rateRange.lowerBound)
    }

    @Test
    func formatsRateText() {
        #expect(TickerText.rateText(2.25) == "2x")
    }
}
