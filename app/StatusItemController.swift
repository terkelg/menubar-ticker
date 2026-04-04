import AppKit
import SwiftUI

@MainActor
final class StatusItemController: NSObject, NSPopoverDelegate {
    private let item = NSStatusBar.system.statusItem(withLength: TickerLabel.width)
    private let popover = NSPopover()
    private let session = TickerSession()
    private let login = LaunchAtLogin()
    private var local: Any?
    private var global: Any?

    override init() {
        super.init()
        setUpPopover()
        setUpItem()
    }

    private func setUpPopover() {
        popover.behavior = .transient
        popover.delegate = self
        popover.contentViewController = NSHostingController(
            rootView: TickerMenuView(session: session, login: login, close: closePopover)
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
            closePopover()
            return
        }

        popover.show(relativeTo: target.bounds, of: target, preferredEdge: .minY)
        popover.contentViewController?.view.window?.becomeKey()
    }

    private func closePopover() {
        guard popover.isShown else { return }
        popover.performClose(nil)
    }

    private func startMonitoring() {
        guard local == nil, global == nil else { return }

        let mask: NSEvent.EventTypeMask = [.leftMouseDown, .rightMouseDown, .otherMouseDown, .keyDown]

        local = NSEvent.addLocalMonitorForEvents(matching: mask) { [weak self] event in
            self?.handleLocal(event)
        }

        global = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown]) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.closePopover()
            }
        }
    }

    private func stopMonitoring() {
        if let local {
            NSEvent.removeMonitor(local)
            self.local = nil
        }

        if let global {
            NSEvent.removeMonitor(global)
            self.global = nil
        }
    }

    private func handleLocal(_ event: NSEvent) -> NSEvent? {
        guard popover.isShown else { return event }

        if event.type == .keyDown, event.keyCode == 53 {
            closePopover()
            return nil
        }

        guard event.type != .keyDown else { return event }
        guard let frame = popover.contentViewController?.view.window?.frame else { return event }

        let point = event.window.map { $0.convertPoint(toScreen: event.locationInWindow) } ?? NSEvent.mouseLocation
        guard PopoverEvent.shouldClose(at: point, in: frame) else { return event }

        // Consume the closing click so the status item can't reopen in the same event.
        closePopover()
        return nil
    }

    func popoverWillShow(_ notification: Notification) {
        startMonitoring()
        session.pause(.popover)
    }

    func popoverDidClose(_ notification: Notification) {
        stopMonitoring()
        session.resume(.popover)
        session.resume(.edit)
    }
}

enum PopoverEvent {
    static func shouldClose(at point: CGPoint, in frame: CGRect) -> Bool {
        !frame.contains(point)
    }
}
