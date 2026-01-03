import SwiftUI
import AppKit

@main
struct MiniNoteApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var noteStore = NoteStore()
    @StateObject private var hotCornerManager = HotCornerManager()
    @StateObject private var menuBarManager = MenuBarManager()

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }

    init() {
        let noteStore = NoteStore()
        let hotCornerManager = HotCornerManager()
        let menuBarManager = MenuBarManager()

        _noteStore = StateObject(wrappedValue: noteStore)
        _hotCornerManager = StateObject(wrappedValue: hotCornerManager)
        _menuBarManager = StateObject(wrappedValue: menuBarManager)

        DispatchQueue.main.async {
            AppState.shared.noteStore = noteStore
            AppState.shared.hotCornerManager = hotCornerManager
            AppState.shared.menuBarManager = menuBarManager

            menuBarManager.setHotCornerManager(hotCornerManager)
        }
    }
}

class AppState {
    static let shared = AppState()
    var noteStore: NoteStore?
    var hotCornerManager: HotCornerManager?
    var menuBarManager: MenuBarManager?
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
