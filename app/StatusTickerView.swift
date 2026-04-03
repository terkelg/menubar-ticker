import SwiftUI

struct StatusTickerView: View {
    let session: TickerSession

    var body: some View {
        TickerLabel(
            text: session.text,
            paused: session.paused,
            rate: session.rate
        )
    }
}
