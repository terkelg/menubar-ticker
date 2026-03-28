import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var status: StatusItemController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        status = StatusItemController()
    }
}
