import Foundation
import ServiceManagement

@MainActor
final class LaunchAtLogin: ObservableObject {
    @Published private(set) var enabled = false
    @Published private(set) var available = true
    @Published private(set) var approval = false
    @Published private(set) var error: String?
    @Published private(set) var note: String?

    private let service = SMAppService.mainApp

    init() {
        reload()
    }

    func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try service.register()
            } else {
                try service.unregister()
            }
            error = nil
        } catch {
            self.error = error.localizedDescription
        }

        reload(clearError: false)
    }

    func openSettings() {
        SMAppService.openSystemSettingsLoginItems()
    }

    func reload(clearError: Bool = true) {
        let status = service.status
        if clearError {
            error = nil
        }
        available = true
        approval = status == .requiresApproval
        enabled = status == .enabled || approval
        note = message(for: status)
    }

    private func message(for status: SMAppService.Status) -> String? {
        guard status == .notFound else { return nil }

        let path = Bundle.main.bundleURL.path
        if path.contains("/DerivedData/") {
            return "Launch at login is unavailable while running from Xcode’s DerivedData. Run the app from Applications instead."
        }

        return "Launch at login is unavailable for the current app install."
    }
}
