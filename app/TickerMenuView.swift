import SwiftUI
import TickerCore

struct TickerMenuView: View {
    let session: TickerSession
    let login: LaunchAtLogin
    let close: () -> Void
    @State private var text: String
    @State private var rate: Double
    @State private var launch: Bool

    init(session: TickerSession, login: LaunchAtLogin, close: @escaping () -> Void) {
        self.session = session
        self.login = login
        self.close = close
        _text = State(initialValue: session.list.joined(separator: "\n"))
        _rate = State(initialValue: session.rate)
        _launch = State(initialValue: login.enabled)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            GroupBox {
                NonWrappingTextEditor(text: $text, onFocusChange: setFocused)
                    .frame(minHeight: 104)
            } label: {
                Text("One sentence per line")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            GroupBox("Playback") {
                VStack(alignment: .leading, spacing: 8) {
                    Slider(value: $rate, in: TickerText.rateRange, step: 0.1)

                    HStack(spacing: 0) {
                        Text(TickerText.rateText(TickerText.rateRange.lowerBound))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(.secondary)

                        Text(TickerText.rateText(TickerText.rateFallback))
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.secondary)

                        Text(TickerText.rateText(TickerText.rateRange.upperBound))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundStyle(.secondary)
                    }
                    .font(.caption)
                }
            }

            GroupBox("General") {
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Start on Login", isOn: $launch)

                    if login.approval {
                        HStack(spacing: 8) {
                            Text("Needs approval in System Settings")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Button("Open Settings", action: login.openSettings)
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
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
                Button("Close", action: close)

                Spacer(minLength: 0)

                Button("Quit", action: quit)
                    .keyboardShortcut("q")
            }
        }
        .padding(16)
        .frame(width: 360, alignment: .leading)
        .onAppear { login.reload() }
        .onDisappear(perform: finishEditing)
        .onChange(of: text) { _, value in
            session.setList(lines(value))
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
    }

    private func lines(_ text: String) -> [String] {
        text.split(whereSeparator: \.isNewline).map(String.init)
    }

    private func sync() {
        let text = session.list.joined(separator: "\n")

        guard self.text != text else { return }
        self.text = text
    }

    private func finishEditing() {
        session.resume(.edit)
        sync()
    }

    private func setFocused(_ focused: Bool) {
        if focused {
            session.pause(.edit)
        } else {
            finishEditing()
        }
    }

    private func quit() {
        NSApp.terminate(nil)
    }
}

#Preview("Popover") {
    TickerMenuView(session: TickerSession(), login: LaunchAtLogin(), close: {})
}
