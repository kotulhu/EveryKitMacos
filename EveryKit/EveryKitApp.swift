import SwiftUI
import AppKit

@main
struct EveryKitApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra {
            ContentView()
        } label: {
            Image("MenuBarIcon")
                .renderingMode(.template)
                .accessibilityLabel("EveryKit")
        }
        .menuBarExtraStyle(.window)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var instanceLock: SingleInstanceLock?

    override init() {
        super.init()
        instanceLock = SingleInstanceLock()
    }

    func applicationWillFinishLaunching(_ notification: Notification) {
        if instanceLock == nil {
            SingleInstance.activateRunningInstanceAndTerminate()
        }
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard !SingleInstance.isTerminatingDuplicate else {
            return .terminateNow
        }

        let alert = NSAlert()
        alert.messageText = "Выйти из EveryKit?"
        alert.informativeText = "Приложение закроется. Вы сможете снова открыть его из строки меню."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Отмена")
        alert.addButton(withTitle: "Выйти")

        let response = alert.runModal()
        return response == .alertSecondButtonReturn ? .terminateNow : .terminateCancel
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
