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

    func showNote() {
        DispatchQueue.main.async {
            self.isNoteVisible = true
            self.showNoteWindow()
        }
    }

    func hideNote() {
        DispatchQueue.main.async {
            self.isNoteVisible = false
            self.hideNoteWindow()
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
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        window.identifier = NSUserInterfaceItemIdentifier("NoteWindow")
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.center()
        window.isReleasedWhenClosed = false

        // Masquer les boutons de contrôle classiques
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true

        // Fond transparent et coins arrondis
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = true

        guard let noteStore = AppState.shared.noteStore else {
            fatalError("NoteStore not initialized")
        }

        let contentView = NoteEditorView()
            .environmentObject(noteStore)
            .environmentObject(self)
            .background(Color(hex: "#282A35"))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

        window.contentView = NSHostingView(rootView: contentView)

        windowDelegate = WindowDelegate(hotCornerManager: self)
        window.delegate = windowDelegate

        return window
    }
}

// Extension pour supporter les couleurs hexadécimales
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
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
