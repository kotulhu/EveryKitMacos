import AppKit
import Darwin

/// Держит эксклюзивный файловый лок на всё время жизни процесса.
/// Если лок уже занят, значит другой экземпляр EveryKit запущен.
final class SingleInstanceLock {
    private var fileDescriptor: Int32 = -1

    init?() {
        let fileManager = FileManager.default
        guard let support = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        let directory = support.appendingPathComponent("EveryKit", isDirectory: true)
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        let path = directory.appendingPathComponent("single-instance.lock").path

        fileDescriptor = path.withCString { open($0, O_CREAT | O_RDWR, S_IRUSR | S_IWUSR) }
        guard fileDescriptor >= 0 else { return nil }

        guard flock(fileDescriptor, LOCK_EX | LOCK_NB) == 0 else {
            close(fileDescriptor)
            fileDescriptor = -1
            return nil
        }
    }

    deinit {
        guard fileDescriptor >= 0 else { return }
        flock(fileDescriptor, LOCK_UN)
        close(fileDescriptor)
    }
}

enum SingleInstance {
    static func activateRunningInstanceAndTerminate() {
        let identifier = Bundle.main.bundleIdentifier ?? "local.everykit.EveryKit"
        let currentPID = ProcessInfo.processInfo.processIdentifier
        NSRunningApplication.runningApplications(withBundleIdentifier: identifier)
            .first { $0.processIdentifier != currentPID }?
            .activate(options: [.activateAllWindows])
        NSApp.terminate(nil)
    }
}
