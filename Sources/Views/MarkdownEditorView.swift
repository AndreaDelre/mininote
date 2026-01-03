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
        override func mouseDown(with event: NSEvent) {
            // Convertir le point du clic dans le système de coordonnées de la vue
            let point = self.convert(event.locationInWindow, from: nil)
            
            // Trouver l'index du caractère sous la souris
            let layoutManager = self.layoutManager!
            let textContainer = self.textContainer!
            let charIndex = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
            
            if charIndex < self.string.count {
                // Analyser la ligne cliquée
                let nsString = self.string as NSString
                let lineRange = nsString.lineRange(for: NSRange(location: charIndex, length: 0))
                let line = nsString.substring(with: lineRange)
                
                // Vérifier si c'est une checkbox
                // On cherche exactement "- [ ]" ou "- [x]" au début (ou après whitespace)
                // Mais pour simplifier l'UX, on regarde si le clic est sur les 5 premiers caractères de la ligne checkbox
                
                let checkboxPattern = #"- \[( |x)\]"#
                if let regex = try? NSRegularExpression(pattern: checkboxPattern, options: []) {
                    let rangeInLine = NSRange(location: 0, length: (line as NSString).length)
                    if let match = regex.firstMatch(in: line, options: [], range: rangeInLine) {
                        // La checkbox est trouvée dans la ligne
                        // Calculons sa position absolue dans le texte global
                        let checkboxAbsStart = lineRange.location + match.range.location
                        let checkboxAbsEnd = checkboxAbsStart + match.range.length // Longueur de "- [ ]" (5 chars)
                        
                        // Si le clic est DANS la zone de la checkbox
                        if charIndex >= checkboxAbsStart && charIndex < checkboxAbsEnd {
                            // C'est un clic sur la checkbox -> Toggle
                            if let delegate = self.delegate as? Coordinator {
                                delegate.toggleCheckbox(at: lineRange, line: line)
                            }
                            // IMPORTANT : On ne fait pas super.mouseDown() pour éviter de changer la sélection
                            return
                        }
                    }
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

        init(content: Binding<String>) {
            self._content = content
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView, !isRendering else { return }
            content = textView.string
            renderMarkdown()
        }
        
        func toggleCheckbox(at lineRange: NSRange, line: String) {
            guard let textView = textView else { return }
            
            var newContent = textView.string
            let nsNewContent = newContent as NSString
            
            if line.contains("- [ ]") {
                let newLine = line.replacingOccurrences(of: "- [ ]", with: "- [x]")
                newContent = nsNewContent.replacingCharacters(in: lineRange, with: newLine)
            } else if line.contains("- [x]") {
                let newLine = line.replacingOccurrences(of: "- [x]", with: "- [ ]")
                newContent = nsNewContent.replacingCharacters(in: lineRange, with: newLine)
            }
            
            // Mise à jour via le binding SwiftUI
            self.content = newContent
            // Mise à jour locale immédiate pour réactivité
            textView.string = newContent
            renderMarkdown()
        }

        func renderMarkdown() {
            guard let textView = textView, let storage = textView.textStorage else { return }
            isRendering = true

            let fullRange = NSRange(location: 0, length: storage.length)
            
            storage.setAttributes([
                .font: NSFont.systemFont(ofSize: 15),
                .foregroundColor: NSColor.labelColor
            ], range: fullRange)

            let text = storage.string
            
            text.enumerateSubstrings(in: text.startIndex..., options: .byLines) { (substring, substringRange, _, _) in
                guard let line = substring else { return }
                let lineRange = NSRange(substringRange, in: text)
                
                // 1. Titles
                if line.hasPrefix("#") {
                    let level = line.prefix(while: { $0 == "#" }).count
                    let fontSize: CGFloat = level == 1 ? 22 : (level == 2 ? 18 : 16)
                    storage.addAttribute(.font, value: NSFont.boldSystemFont(ofSize: fontSize), range: lineRange)
                    if level == 1 {
                        storage.addAttribute(.foregroundColor, value: NSColor.systemBlue, range: lineRange)
                    }
                }
                
                // 2. Bold
                self.applyRegex(pattern: #"\*\*(.+?)\*\*"#, in: line, lineOffset: lineRange.location, storage: storage) { range in
                    storage.addAttribute(.font, value: NSFont.boldSystemFont(ofSize: 15), range: range)
                }

                // 3. Inline Code
                self.applyRegex(pattern: #"`(.+?)`"#, in: line, lineOffset: lineRange.location, storage: storage) { range in
                    storage.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: 14, weight: .medium), range: range)
                    storage.addAttribute(.backgroundColor, value: NSColor.labelColor.withAlphaComponent(0.05), range: range)
                }
                
                // 4. Checkboxes
                if line.contains("- [ ]") {
                    let nsLine = line as NSString
                    let rangeInLine = nsLine.range(of: "- [ ]")
                    let checkboxRange = NSRange(location: lineRange.location + rangeInLine.location, length: rangeInLine.length)
                    storage.addAttribute(.foregroundColor, value: NSColor.systemBlue, range: checkboxRange)
                    storage.addAttribute(.font, value: NSFont.boldSystemFont(ofSize: 15), range: checkboxRange)
                } else if line.contains("- [x]") {
                    storage.addAttribute(.foregroundColor, value: NSColor.secondaryLabelColor, range: lineRange)
                    storage.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: lineRange)
                }
            }

            isRendering = false
        }

        private func applyRegex(pattern: String, in line: String, lineOffset: Int, storage: NSTextStorage, action: (NSRange) -> Void) {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return }
            let range = NSRange(location: 0, length: (line as NSString).length)
            regex.enumerateMatches(in: line, options: [], range: range) { match, _, _ in
                if let matchRange = match?.range(at: 0) {
                    let fullRange = NSRange(location: lineOffset + matchRange.location, length: matchRange.length)
                    action(fullRange)
                }
            }
        }
    }
}