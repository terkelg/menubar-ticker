import AppKit
import SwiftUI
import TickerCore

struct TickerLabel: View {
    static let speed = 30.0
    static let width: CGFloat = 180
    static let height: CGFloat = 18
    static let fade: CGFloat = 3
    private static let fadeRatio = min(fade / width, 0.5)
    fileprivate static let font = Font.system(size: 12, weight: .medium)
    private static let nsFont = NSFont.systemFont(ofSize: 12, weight: .medium)
    private static let mask = LinearGradient(
        stops: [
            .init(color: .clear, location: 0),
            .init(color: .black, location: fadeRatio),
            .init(color: .black, location: 1 - fadeRatio),
            .init(color: .clear, location: 1),
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    let text: String
    var paused = false
    var rate = TickerText.rateFallback

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var start = Date.now
    @State private var elapsed = 0.0
    @State private var unit = TickerText.loop(TickerText.fallback)
    @State private var span = CGFloat(1)
    @State private var copies = 3

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 120.0, paused: motionPaused)) { ctx in
            TickerTrack(text: unit, span: span, copies: copies, x: offset(at: ctx.date))
                .frame(width: Self.width, height: Self.height, alignment: .leading)
                .clipped()
                .mask(Self.mask)
                .compositingGroup()
                .transaction { $0.animation = nil }
        }
        .onAppear { sync(text) }
        .onChange(of: paused) { old, new in
            updatePause(from: old || reduceMotion, to: new || reduceMotion)
        }
        .onChange(of: reduceMotion) { old, new in
            updatePause(from: paused || old, to: paused || new)
        }
        .onChange(of: text) { _, _ in
            sync(text)
        }
        .accessibilityLabel(TickerText.value(text))
        .help(TickerText.value(text))
    }

    private var motionPaused: Bool {
        paused || reduceMotion
    }

    private func updatePause(from old: Bool, to new: Bool) {
        guard old != new else { return }
        if new {
            elapsed += Date.now.timeIntervalSince(start)
        } else {
            start = .now
        }
    }

    private func offset(at date: Date) -> CGFloat {
        let delta = (motionPaused ? elapsed : elapsed + date.timeIntervalSince(start)) * Self.speed * rate
        return -CGFloat(delta.truncatingRemainder(dividingBy: Double(span)))
    }

    private func sync(_ raw: String) {
        let text = TickerText.loop(raw)
        unit = text
        let span = Self.measure(text)
        self.span = span
        copies = Self.count(for: span)
        elapsed = 0
        start = .now
    }

    private static func count(for span: CGFloat) -> Int {
        max(Int(ceil(width / span)) + 2, 3)
    }

    private static func measure(_ text: String) -> CGFloat {
        let size = (text as NSString).size(withAttributes: [.font: nsFont])
        return max(ceil(size.width), 1)
    }
}

private struct TickerTrack: View {
    let text: String
    let span: CGFloat
    let copies: Int
    let x: CGFloat

    var body: some View {
        ZStack(alignment: .leading) {
            ForEach(0..<copies, id: \.self) { i in
                TickerSlice(text: text)
                    .offset(x: x + CGFloat(i) * span)
            }
        }
    }
}

private struct TickerSlice: View {
    let text: String

    var body: some View {
        Text(text)
            .font(TickerLabel.font)
            .lineLimit(1)
            .fixedSize()
    }
}

#Preview("Ticker") {
    VStack(alignment: .leading, spacing: 12) {
        Text("Menu Bar Preview")
            .font(.headline)

        TickerLabel(text: "This sentence keeps looping forever")
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.quaternary.opacity(0.7), in: Capsule())
    }
    .padding(20)
    .frame(width: 280, alignment: .leading)
}
