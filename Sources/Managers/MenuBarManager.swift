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
        let config = NSImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        if let image = NSImage(systemSymbolName: "square.and.pencil", accessibilityDescription: "MiniNote") {
            return image.withSymbolConfiguration(config) ?? image
        }
        return NSImage(named: NSImage.actionTemplateName) ?? NSImage()
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
