import Foundation
import AppKit
import SwiftUI
import Combine

class HotCornerManager: ObservableObject {
    @Published var isNoteVisible = false

    private var eventMonitor: Any?
    private var checkTimer: Timer?
    private let cornerThreshold: CGFloat = 10
    private var isInCorner = false
    private var windowDelegate: WindowDelegate?

    init() {
        checkAccessibilityPermissions()
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    private func checkAccessibilityPermissions() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessibilityEnabled = AXIsProcessTrustedWithOptions(options)

        if !accessibilityEnabled {
            print("Accessibility permissions required. Please enable in System Preferences.")
        }
    }

    private func startMonitoring() {
        checkTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.checkMousePosition()
        }
    }

    private func stopMonitoring() {
        checkTimer?.invalidate()
        checkTimer = nil
    }

    private func checkMousePosition() {
        guard let screen = NSScreen.main else { return }

        let mouseLocation = NSEvent.mouseLocation
        let screenFrame = screen.frame

        let bottomRight = CGPoint(
            x: screenFrame.maxX,
            y: screenFrame.minY
        )

        let distance = sqrt(
            pow(mouseLocation.x - bottomRight.x, 2) +
            pow(mouseLocation.y - bottomRight.y, 2)
        )

        let isCurrentlyInCorner = distance <= cornerThreshold

        if isCurrentlyInCorner && !isInCorner {
            isInCorner = true
            toggleNote()
        } else if !isCurrentlyInCorner {
            isInCorner = false
        }
    }

    private func toggleNote() {
        DispatchQueue.main.async {
            self.isNoteVisible.toggle()

            if self.isNoteVisible {
                self.showNoteWindow()
            } else {
                self.hideNoteWindow()
            }
        }
    }

    private func showNoteWindow() {
        if let window = NSApp.windows.first(where: { $0.identifier?.rawValue == "NoteWindow" }) {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        } else {
            let window = createNoteWindow()
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func hideNoteWindow() {
        if let window = NSApp.windows.first(where: { $0.identifier?.rawValue == "NoteWindow" }) {
            window.orderOut(nil)
        }
    }

    private func createNoteWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 700),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        window.identifier = NSUserInterfaceItemIdentifier("NoteWindow")
        window.title = "MiniNote"
        window.center()
        window.isReleasedWhenClosed = false

        guard let noteStore = AppState.shared.noteStore else {
            fatalError("NoteStore not initialized")
        }

        let contentView = NoteEditorView()
            .environmentObject(noteStore)
            .environmentObject(self)

        window.contentView = NSHostingView(rootView: contentView)

        windowDelegate = WindowDelegate(hotCornerManager: self)
        window.delegate = windowDelegate

        return window
    }
}

class WindowDelegate: NSObject, NSWindowDelegate {
    weak var hotCornerManager: HotCornerManager?

    init(hotCornerManager: HotCornerManager) {
        self.hotCornerManager = hotCornerManager
    }

    func windowWillClose(_ notification: Notification) {
        hotCornerManager?.isNoteVisible = false
    }
}
