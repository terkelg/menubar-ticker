import SwiftUI

struct StatusTickerView: View {
    @ObservedObject var session: TickerSession

    var body: some View {
        TickerLabel(
            text: session.text,
            paused: session.paused,
            rate: session.rate
        )
    }
}
