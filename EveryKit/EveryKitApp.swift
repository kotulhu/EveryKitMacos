import SwiftUI

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

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
