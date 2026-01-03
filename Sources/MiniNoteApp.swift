import SwiftUI
import AppKit

@main
struct MiniNoteApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var noteStore = NoteStore()
    @StateObject private var hotCornerManager = HotCornerManager()

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }

    init() {
        let noteStore = NoteStore()
        let hotCornerManager = HotCornerManager()
        _noteStore = StateObject(wrappedValue: noteStore)
        _hotCornerManager = StateObject(wrappedValue: hotCornerManager)

        DispatchQueue.main.async {
            AppState.shared.noteStore = noteStore
            AppState.shared.hotCornerManager = hotCornerManager
        }
    }
}

class AppState {
    static let shared = AppState()
    var noteStore: NoteStore?
    var hotCornerManager: HotCornerManager?
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
