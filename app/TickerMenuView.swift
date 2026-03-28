import AppKit
import SwiftUI
import TickerCore

struct TickerMenuView: View {
    @ObservedObject var session: TickerSession
    @ObservedObject var login: LaunchAtLogin
    @State private var text: String
    @State private var rate: Double
    @State private var launch: Bool
    @FocusState private var focused: Bool

    init(session: TickerSession, login: LaunchAtLogin) {
        self.session = session
        self.login = login
        _text = State(initialValue: session.text)
        _rate = State(initialValue: session.rate)
        _launch = State(initialValue: login.enabled)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            TextField("Type the sentence to loop in the menu bar", text: $text, axis: .vertical)
                .textFieldStyle(.plain)
                .font(.title3)
                .lineLimit(3, reservesSpace: true)
                .padding(12)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
                .focused($focused)

            VStack(alignment: .leading, spacing: 8) {
                Slider(value: $rate, in: TickerText.rateRange, step: 0.1) {
                    Text("Speed")
                } minimumValueLabel: {
                    Text(TickerText.rateText(TickerText.rateRange.lowerBound))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } maximumValueLabel: {
                    Text(TickerText.rateText(TickerText.rateRange.upperBound))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Toggle("Start on Login", isOn: $launch)

                if login.approval {
                    HStack(spacing: 8) {
                        Text("Needs approval in System Settings.")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Button("Open Settings") {
                            login.openSettings()
                        }
                        .buttonStyle(.link)
                    }
                } else if let error = login.error {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if let note = login.note {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Button("Quit") {
                NSApp.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .padding(16)
        .frame(width: 320, alignment: .leading)
        .onAppear { login.reload() }
        .onDisappear { session.resume(.edit) }
        .onChange(of: text) { _, value in
            session.setText(value)
        }
        .onChange(of: rate) { _, value in
            session.setRate(value)
        }
        .onChange(of: launch) { _, value in
            login.setEnabled(value)
        }
        .onChange(of: login.enabled) { _, value in
            launch = value
        }
        .onChange(of: focused) { _, value in
            if value {
                session.pause(.edit)
            } else {
                session.resume(.edit)
            }
        }
    }
}

#Preview("Popover") {
    TickerMenuView(session: TickerSession(), login: LaunchAtLogin())
}
