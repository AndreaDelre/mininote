import SwiftUI
import AppKit

struct MarkdownEditorView: NSViewRepresentable {
    @Binding var content: String

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView

        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.font = .systemFont(ofSize: 14)
        textView.textColor = .labelColor
        textView.backgroundColor = .textBackgroundColor
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.string = content

        let clickRecognizer = NSClickGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleClick(_:)))
        textView.addGestureRecognizer(clickRecognizer)

        context.coordinator.textView = textView
        context.coordinator.updateRendering()

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        let textView = nsView.documentView as! NSTextView
        if textView.string != content {
            let selectedRange = textView.selectedRange()
            textView.string = content
            textView.setSelectedRange(selectedRange)
            context.coordinator.updateRendering()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(content: $content)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        @Binding var content: String
        weak var textView: NSTextView?

        init(content: Binding<String>) {
            self._content = content
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            content = textView.string
            updateRendering()
        }

        func updateRendering() {
            guard let textView = textView else { return }
            let text = textView.string

            let storage = textView.textStorage!
            let fullRange = NSRange(location: 0, length: storage.length)

            storage.removeAttribute(.foregroundColor, range: fullRange)
            storage.removeAttribute(.font, range: fullRange)
            storage.removeAttribute(.backgroundColor, range: fullRange)

            storage.addAttribute(.font, value: NSFont.systemFont(ofSize: 14), range: fullRange)
            storage.addAttribute(.foregroundColor, value: NSColor.labelColor, range: fullRange)

            let lines = text.components(separatedBy: .newlines)
            var currentIndex = 0

            for line in lines {
                let lineLength = (line as NSString).length
                let lineRange = NSRange(location: currentIndex, length: lineLength)

                if line.hasPrefix("# ") {
                    storage.addAttribute(.font, value: NSFont.boldSystemFont(ofSize: 24), range: lineRange)
                } else if line.hasPrefix("## ") {
                    storage.addAttribute(.font, value: NSFont.boldSystemFont(ofSize: 20), range: lineRange)
                } else if line.hasPrefix("### ") {
                    storage.addAttribute(.font, value: NSFont.boldSystemFont(ofSize: 18), range: lineRange)
                } else if line.hasPrefix("- [ ] ") || line.hasPrefix("- [x] ") || line.hasPrefix("- [X] ") {
                    renderTaskLine(line: line, lineRange: lineRange, storage: storage)
                } else if line.hasPrefix("- ") || line.hasPrefix("* ") || line.hasPrefix("+ ") {
                    storage.addAttribute(.foregroundColor, value: NSColor.secondaryLabelColor, range: NSRange(location: currentIndex, length: 2))
                }

                renderInlineMarkdown(in: line, range: lineRange, storage: storage)

                currentIndex += lineLength + 1
            }
        }

        private func renderTaskLine(line: String, lineRange: NSRange, storage: NSTextStorage) {
            let isChecked = line.hasPrefix("- [x] ") || line.hasPrefix("- [X] ")

            storage.addAttribute(.foregroundColor, value: NSColor.secondaryLabelColor, range: NSRange(location: lineRange.location, length: 6))

            let checkbox = isChecked ? "☑" : "☐"
            let checkboxRange = NSRange(location: lineRange.location + 2, length: 3)

            if checkboxRange.location + checkboxRange.length <= storage.length {
                storage.replaceCharacters(in: checkboxRange, with: checkbox + " ")
            }

            let contentStartIndex = lineRange.location + 6
            if isChecked && contentStartIndex < lineRange.location + lineRange.length {
                let contentRange = NSRange(location: contentStartIndex, length: lineRange.length - 6)
                storage.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: contentRange)
                storage.addAttribute(.foregroundColor, value: NSColor.tertiaryLabelColor, range: contentRange)
            }
        }

        private func renderInlineMarkdown(in line: String, range: NSRange, storage: NSTextStorage) {
            let boldPattern = "\\*\\*(.+?)\\*\\*"
            let italicPattern = "\\*(.+?)\\*"
            let codePattern = "`(.+?)`"

            applyPattern(boldPattern, in: line, range: range, storage: storage) { matchRange in
                storage.addAttribute(.font, value: NSFont.boldSystemFont(ofSize: 14), range: matchRange)
            }

            applyPattern(italicPattern, in: line, range: range, storage: storage) { matchRange in
                storage.addAttribute(.font, value: NSFont.systemFont(ofSize: 14).italic(), range: matchRange)
            }

            applyPattern(codePattern, in: line, range: range, storage: storage) { matchRange in
                storage.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: 13, weight: .regular), range: matchRange)
                storage.addAttribute(.backgroundColor, value: NSColor.quaternaryLabelColor.withAlphaComponent(0.3), range: matchRange)
            }
        }

        private func applyPattern(_ pattern: String, in line: String, range: NSRange, storage: NSTextStorage, apply: (NSRange) -> Void) {
            guard let regex = try? NSRegularExpression(pattern: pattern) else { return }
            let matches = regex.matches(in: line, range: NSRange(location: 0, length: line.count))

            for match in matches {
                let matchRange = NSRange(location: range.location + match.range.location, length: match.range.length)
                if matchRange.location + matchRange.length <= storage.length {
                    apply(matchRange)
                }
            }
        }

        func textView(_ textView: NSTextView, clickedOnLink link: Any, at charIndex: Int) -> Bool {
            if let url = link as? URL {
                NSWorkspace.shared.open(url)
                return true
            }
            return false
        }

        @objc func handleClick(_ recognizer: NSClickGestureRecognizer) {
            guard let textView = textView, recognizer.state == .ended else { return }

            let point = recognizer.location(in: textView)
            let characterIndex = textView.characterIndexForInsertion(at: point)

            guard characterIndex < textView.string.count else { return }

            let text = textView.string
            let lines = text.components(separatedBy: .newlines)
            var currentIndex = 0

            for (lineNumber, line) in lines.enumerated() {
                let lineLength = (line as NSString).length
                let lineEndIndex = currentIndex + lineLength

                if characterIndex >= currentIndex && characterIndex <= lineEndIndex {
                    if line.hasPrefix("- [ ] ") || line.hasPrefix("- [x] ") || line.hasPrefix("- [X] ") {
                        let checkboxRange = NSRange(location: currentIndex, length: 6)

                        if characterIndex >= checkboxRange.location && characterIndex < checkboxRange.location + 6 {
                            toggleCheckbox(at: lineNumber, in: textView)
                            return
                        }
                    }
                    break
                }

                currentIndex = lineEndIndex + 1
            }
        }

        private func toggleCheckbox(at lineNumber: Int, in textView: NSTextView) {
            let text = textView.string
            var lines = text.components(separatedBy: .newlines)

            guard lineNumber < lines.count else { return }

            let line = lines[lineNumber]
            if line.hasPrefix("- [ ] ") {
                lines[lineNumber] = line.replacingOccurrences(of: "- [ ] ", with: "- [x] ", options: [], range: line.startIndex..<line.index(line.startIndex, offsetBy: 6))
            } else if line.hasPrefix("- [x] ") || line.hasPrefix("- [X] ") {
                lines[lineNumber] = line.replacingOccurrences(of: "- [x] ", with: "- [ ] ", options: [], range: line.startIndex..<line.index(line.startIndex, offsetBy: 6))
                lines[lineNumber] = lines[lineNumber].replacingOccurrences(of: "- [X] ", with: "- [ ] ", options: [], range: lines[lineNumber].startIndex..<lines[lineNumber].index(lines[lineNumber].startIndex, offsetBy: 6))
            }

            let selectedRange = textView.selectedRange()
            textView.string = lines.joined(separator: "\n")
            content = textView.string
            textView.setSelectedRange(selectedRange)
            updateRendering()
        }
    }
}

extension NSFont {
    func italic() -> NSFont {
        let descriptor = fontDescriptor.withSymbolicTraits(.italic)
        return NSFont(descriptor: descriptor, size: pointSize) ?? self
    }
}
