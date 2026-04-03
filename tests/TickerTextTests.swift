import Testing
@testable import TickerCore

struct TickerTextTests {
    @Test
    func trimsText() {
        #expect(TickerText.value("  hello world  ") == "hello world")
    }

    @Test
    func keepsOneRow() {
        #expect(TickerText.rows([]) == [TickerText.fallback])
    }

    @Test
    func fallsBackWhenBlank() {
        #expect(TickerText.value(" \n ") == TickerText.fallback)
    }

    @Test
    func joinsRowsInOrder() {
        #expect(TickerText.value([" first ", "second", " third "]) == "first • second • third")
    }

    @Test
    func dropsBlankRows() {
        #expect(TickerText.value(["first", " \n ", "second"]) == "first • second")
    }

    @Test
    func dropsEdgeBlankRows() {
        #expect(TickerText.rows(["", "first", ""]) == ["first"])
    }

    @Test
    func fallsBackWhenRowsAreBlank() {
        #expect(TickerText.value([" \n ", ""]) == TickerText.fallback)
    }

    @Test
    func normalizesRowsIdempotently() {
        let rows = TickerText.rows(["", "first", "", "second", ""])
        #expect(TickerText.rows(rows) == rows)
    }

    @Test
    func appendsDot() {
        #expect(TickerText.loop("hello world") == "hello world • ")
    }

    @Test
    func appendsDotToRows() {
        #expect(TickerText.loop(["first", "second"]) == "first • second • ")
    }

    @Test
    func appendsDotToFallbackRows() {
        #expect(TickerText.loop(["", " \n "]) == "\(TickerText.fallback)\(TickerText.dot)")
    }

    @Test
    func appendsDotToFallback() {
        #expect(TickerText.loop(" \n ") == "\(TickerText.fallback)\(TickerText.dot)")
    }

    @Test
    func clampsRateLow() {
        #expect(TickerText.rate(0.1) == TickerText.rateRange.lowerBound)
    }

    @Test
    func clampsRateHigh() {
        #expect(TickerText.rate(9) == TickerText.rateRange.upperBound)
    }

    @Test
    func formatsRateText() {
        #expect(TickerText.rateText(1.25) == "1.25x")
    }
}
