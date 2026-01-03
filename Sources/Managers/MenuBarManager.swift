import AppKit
import SwiftUI

class MenuBarManager: ObservableObject {
    private var statusItem: NSStatusItem?
    private weak var hotCornerManager: HotCornerManager?

    init() {
        setupMenuBar()
    }

    func setHotCornerManager(_ manager: HotCornerManager) {
        self.hotCornerManager = manager
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            button.image = createNoteIcon()
            button.action = #selector(statusItemClicked)
            button.target = self
        }

        setupMenu()
    }

    private func createNoteIcon() -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size)

        image.lockFocus()

        NSColor.labelColor.setFill()

        let path = NSBezierPath()
        path.move(to: NSPoint(x: 3, y: 2))
        path.line(to: NSPoint(x: 13, y: 2))
        path.line(to: NSPoint(x: 15, y: 4))
        path.line(to: NSPoint(x: 15, y: 16))
        path.line(to: NSPoint(x: 3, y: 16))
        path.close()
        path.lineWidth = 1.5
        path.stroke()

        let line1 = NSBezierPath()
        line1.move(to: NSPoint(x: 5, y: 13))
        line1.line(to: NSPoint(x: 13, y: 13))
        line1.lineWidth = 1.0
        line1.stroke()

        let line2 = NSBezierPath()
        line2.move(to: NSPoint(x: 5, y: 10))
        line2.line(to: NSPoint(x: 13, y: 10))
        line2.lineWidth = 1.0
        line2.stroke()

        let line3 = NSBezierPath()
        line3.move(to: NSPoint(x: 5, y: 7))
        line3.line(to: NSPoint(x: 11, y: 7))
        line3.lineWidth = 1.0
        line3.stroke()

        image.unlockFocus()
        image.isTemplate = true

        return image
    }

    @objc private func statusItemClicked() {
        guard let hotCornerManager = hotCornerManager else { return }

        if hotCornerManager.isNoteVisible {
            hotCornerManager.hideNote()
        } else {
            hotCornerManager.showNote()
        }
    }

    private func setupMenu() {
        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "Show/Hide Note", action: #selector(statusItemClicked), keyEquivalent: "n"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "About MiniNote", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "MiniNote v1.0.0"
        alert.informativeText = "A simple markdown note-taking app with hot corner.\n\nMove your cursor to the bottom-right corner to show/hide your notes.\n\nBuilt with Swift & SwiftUI."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
