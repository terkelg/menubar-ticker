import AppKit
import SwiftUI

@MainActor
final class StatusItemController: NSObject, NSPopoverDelegate {
    private let item = NSStatusBar.system.statusItem(withLength: TickerLabel.width)
    private let popover = NSPopover()
    private let session = TickerSession()
    private let login = LaunchAtLogin()

    override init() {
        super.init()
        setUpPopover()
        setUpItem()
    }

    private func setUpPopover() {
        popover.behavior = .transient
        popover.delegate = self
        popover.contentViewController = NSHostingController(
            rootView: TickerMenuView(session: session, login: login)
        )
    }

    private func setUpItem() {
        guard let button = item.button else { return }

        let view = PassthroughHostingView(rootView: StatusTickerView(session: session))
        view.frame = button.bounds
        view.autoresizingMask = [.width, .height]

        button.title = ""
        button.image = nil
        button.target = self
        button.action = #selector(togglePopover)
        button.addSubview(view)
    }

    @objc private func togglePopover() {
        guard let target = item.button else { return }

        if popover.isShown {
            popover.performClose(nil)
            return
        }

        popover.show(relativeTo: target.bounds, of: target, preferredEdge: .minY)
        popover.contentViewController?.view.window?.becomeKey()
    }

    func popoverWillShow(_ notification: Notification) {
        session.pause(.popover)
    }

    func popoverDidClose(_ notification: Notification) {
        session.resume(.popover)
        session.resume(.edit)
    }
}
