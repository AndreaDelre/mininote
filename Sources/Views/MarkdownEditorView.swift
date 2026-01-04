import SwiftUI
import AppKit

struct MarkdownEditorView: NSViewRepresentable {
    @Binding var content: String

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        
        // Remplacer le NSTextView standard par notre custom class
        let textView = MiniNoteTextView()
        textView.textContainer?.containerSize = NSSize(width: scrollView.contentSize.width, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        scrollView.documentView = textView
        
        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.font = .systemFont(ofSize: 15, weight: .regular)
        textView.textColor = .labelColor
        textView.backgroundColor = .clear
        textView.drawsBackground = false
        scrollView.drawsBackground = false

        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isAutomaticLinkDetectionEnabled = true
        textView.isAutomaticDataDetectionEnabled = true
        textView.smartInsertDeleteEnabled = false
        textView.isContinuousSpellCheckingEnabled = false
        textView.isGrammarCheckingEnabled = false

        textView.string = content
        context.coordinator.textView = textView
        
        // Initial render
        DispatchQueue.main.async {
            context.coordinator.renderMarkdown()
        }

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? MiniNoteTextView else { return }
        if textView.string != content {
            let selectedRange = textView.selectedRange()
            textView.string = content
            textView.setSelectedRange(selectedRange)
            context.coordinator.renderMarkdown()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(content: $content)
    }

    // Custom TextView pour gérer le clic précisément
    class MiniNoteTextView: NSTextView {
        override func draw(_ dirtyRect: NSRect) {
            super.draw(dirtyRect)

            // Draw checkboxes over the invisible markdown text
            guard let storage = textStorage, let layoutManager = layoutManager, let textContainer = textContainer else { return }

            let checkboxSize: CGFloat = 16
            let textRange = NSRange(location: 0, length: storage.length)

            storage.enumerateAttribute(NSAttributedString.Key("isCheckbox"), in: textRange, options: []) { value, range, _ in
                guard let isChecked = value as? Bool else { return }

                // Get the glyph position for this character
                let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
                guard glyphRange.length > 0 else { return }

                let glyphRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
                let checkboxRect = CGRect(
                    x: glyphRect.origin.x + textContainerInset.width,
                    y: glyphRect.origin.y + textContainerInset.height + (glyphRect.height - checkboxSize) / 2,
                    width: checkboxSize,
                    height: checkboxSize
                )

                // Draw the checkbox
                let path = NSBezierPath(roundedRect: checkboxRect.insetBy(dx: 0.75, dy: 0.75), xRadius: 3, yRadius: 3)

                if isChecked {
                    NSColor.systemBlue.setFill()
                    path.fill()
                }

                NSColor.tertiaryLabelColor.setStroke()
                path.lineWidth = 1.5
                path.stroke()

                // Draw checkmark if checked
                if isChecked {
                    let checkPath = NSBezierPath()
                    let checkSize = checkboxSize * 0.6
                    let offsetX = checkboxRect.minX + (checkboxSize - checkSize) / 2
                    let offsetY = checkboxRect.minY + (checkboxSize - checkSize) / 2

                    checkPath.move(to: CGPoint(x: offsetX + checkSize * 0.2, y: offsetY + checkSize * 0.5))
                    checkPath.line(to: CGPoint(x: offsetX + checkSize * 0.4, y: offsetY + checkSize * 0.3))
                    checkPath.line(to: CGPoint(x: offsetX + checkSize * 0.8, y: offsetY + checkSize * 0.7))

                    NSColor.white.setStroke()
                    checkPath.lineWidth = 2
                    checkPath.lineCapStyle = .round
                    checkPath.lineJoinStyle = .round
                    checkPath.stroke()
                }
            }
        }

        override func mouseDown(with event: NSEvent) {
            // Convertir le point du clic dans le système de coordonnées de la vue
            let point = self.convert(event.locationInWindow, from: nil)

            // Trouver l'index du caractère sous la souris
            let layoutManager = self.layoutManager!
            let textContainer = self.textContainer!
            let charIndex = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

            if charIndex < self.textStorage!.length {
                // Check if we clicked on a checkbox
                if let isChecked = self.textStorage?.attribute(NSAttributedString.Key("isCheckbox"), at: charIndex, effectiveRange: nil) as? Bool {
                    // Toggle the checkbox
                    if let delegate = self.delegate as? Coordinator {
                        delegate.toggleCheckbox(at: charIndex, currentState: isChecked)
                    }
                    return
                }
            }

            // Comportement standard (déplacer curseur, sélectionner texte)
            super.mouseDown(with: event)
        }
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        @Binding var content: String
        weak var textView: NSTextView?
        private var isRendering = false
        private let parser = MarkdownParser()

        init(content: Binding<String>) {
            self._content = content
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView, !isRendering else { return }
            content = textView.string
            renderMarkdown()
        }

        func toggleCheckbox(at charIndex: Int, currentState: Bool) {
            guard let textView = textView else { return }

            // Get the line containing the checkbox from the current text
            let currentText = textView.string as NSString
            let lineRange = currentText.lineRange(for: NSRange(location: charIndex, length: 0))
            let line = currentText.substring(with: lineRange)

            // Toggle the checkbox in the markdown
            var newContent = currentText as String

            if currentState {
                // Currently checked, uncheck it
                let newLine = line.replacingOccurrences(of: "- [x]", with: "- [ ]")
                    .replacingOccurrences(of: "- [X]", with: "- [ ]")
                newContent = currentText.replacingCharacters(in: lineRange, with: newLine)
            } else {
                // Currently unchecked, check it
                let newLine = line.replacingOccurrences(of: "- [ ]", with: "- [x]")
                newContent = currentText.replacingCharacters(in: lineRange, with: newLine)
            }

            // Update the content binding
            self.content = newContent
        }

        func renderMarkdown() {
            guard let textView = textView, let storage = textView.textStorage else { return }
            isRendering = true
            
            // Utilisation du nouveau parser AST
            parser.parseAndApply(to: storage)

            isRendering = false
        }
    }
}