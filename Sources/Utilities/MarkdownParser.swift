import Foundation
import Markdown
import AppKit

/// A robust Markdown parser using Apple's swift-markdown library.
/// It converts raw markdown text into styled NSAttributedString.
class MarkdownParser {
    
    private let theme: Theme
    private let highlighter = CodeSyntaxHighlighter()
    
    struct Theme {
        let baseFont: NSFont
        let h1Font: NSFont
        let h2Font: NSFont
        let h3Font: NSFont
        let codeFont: NSFont
        
        let textColor: NSColor
        let secondaryColor: NSColor
        let accentColor: NSColor
        let codeBackgroundColor: NSColor
        let quoteColor: NSColor
        
        static let `default` = Theme(
            baseFont: NSFont(name: "Menlo", size: 15) ?? .monospacedSystemFont(ofSize: 15, weight: .medium),
            h1Font: NSFont(name: "Menlo-Bold", size: 26) ?? .monospacedSystemFont(ofSize: 26, weight: .bold),
            h2Font: NSFont(name: "Menlo-Bold", size: 20) ?? .monospacedSystemFont(ofSize: 20, weight: .bold),
            h3Font: NSFont(name: "Menlo-Bold", size: 17) ?? .monospacedSystemFont(ofSize: 17, weight: .bold),
            codeFont: .monospacedSystemFont(ofSize: 14, weight: .medium),
            textColor: .labelColor,
            secondaryColor: .secondaryLabelColor,
            accentColor: .systemBlue,
            codeBackgroundColor: NSColor.labelColor.withAlphaComponent(0.05),
            quoteColor: .tertiaryLabelColor
        )
    }
    
    init(theme: Theme = .default) {
        self.theme = theme
    }
    
    /// Parses the markdown string and applies attributes to the provided NSTextStorage.
    func parseAndApply(to storage: NSTextStorage) {
        let text = storage.string
        let document = Document(parsing: text)

        storage.beginEditing()

        // 1. Reset base attributes
        let fullRange = NSRange(location: 0, length: storage.length)
        storage.setAttributes([
            .font: theme.baseFont,
            .foregroundColor: theme.textColor
        ], range: fullRange)

        // 2. Walk the AST
        var walker = AttributedStringWalker(storage: storage, text: text, theme: theme, highlighter: highlighter)
        walker.visit(document)

        storage.endEditing()
    }
}

/// A Visitor that walks the Markdown AST and applies attributes to the NSTextStorage
private struct AttributedStringWalker: MarkupWalker {
    let storage: NSTextStorage
    let text: String
    let theme: MarkdownParser.Theme
    let highlighter: CodeSyntaxHighlighter
    
    // Helper to convert SourceRange to NSRange
    private func nsRange(from range: SourceRange?) -> NSRange? {
        guard let range = range else { return nil }
        return self.rangeFromSourceRange(range, in: text)
    }
    
    private func rangeFromSourceRange(_ range: SourceRange, in text: String) -> NSRange? {
        // Naive index calculation
        let start = range.lowerBound
        let end = range.upperBound
        
        guard let startIndex = index(for: start, in: text),
              let endIndex = index(for: end, in: text) else { return nil }
        
        return NSRange(startIndex..<endIndex, in: text)
    }
    
    private func index(for location: SourceLocation, in text: String) -> String.Index? {
        var currentLine = 1
        var currentIndex = text.startIndex
        
        while currentLine < location.line {
            guard let nextLine = text[currentIndex...].firstIndex(of: "\n") else { return nil }
            currentIndex = text.index(after: nextLine)
            currentLine += 1
        }
        
        return text.index(currentIndex, offsetBy: location.column - 1, limitedBy: text.endIndex)
    }
    
    mutating func visitHeading(_ heading: Heading) {
        if let range = nsRange(from: heading.range) {
            let font: NSFont
            let color: NSColor?

            switch heading.level {
            case 1:
                font = theme.h1Font
                color = theme.accentColor
            case 2:
                font = theme.h2Font
                color = nil
            case 3:
                font = theme.h3Font
                color = nil
            default:
                font = NSFont.boldSystemFont(ofSize: 14)
                color = nil
            }

            storage.addAttribute(.font, value: font, range: range)
            if let color = color {
                storage.addAttribute(.foregroundColor, value: color, range: range)
            }
        }
        descendInto(heading)
    }
    
    mutating func visitStrong(_ strong: Strong) {
        if let range = nsRange(from: strong.range) {
            storage.addAttribute(.font, value: NSFont.boldSystemFont(ofSize: 15), range: range)
        }
        descendInto(strong)
    }
    
    mutating func visitEmphasis(_ emphasis: Emphasis) {
        if let range = nsRange(from: emphasis.range) {
            if let currentFont = storage.attribute(.font, at: range.location, effectiveRange: nil) as? NSFont {
                let italicFont = NSFontManager.shared.convert(currentFont, toHaveTrait: .italicFontMask)
                storage.addAttribute(.font, value: italicFont, range: range)
            } else {
                 storage.addAttribute(.font, value: NSFont.systemFont(ofSize: 15).italic(), range: range)
            }
        }
        descendInto(emphasis)
    }
    
    mutating func visitInlineCode(_ inlineCode: InlineCode) {
        if let range = nsRange(from: inlineCode.range) {
            storage.addAttribute(.font, value: theme.codeFont, range: range)
            storage.addAttribute(.backgroundColor, value: theme.codeBackgroundColor, range: range)
            storage.addAttribute(.foregroundColor, value: theme.accentColor, range: range)
        }
    }
    
    mutating func visitCodeBlock(_ codeBlock: CodeBlock) {
        if let range = nsRange(from: codeBlock.range) {
            // Background
            storage.addAttribute(.backgroundColor, value: theme.codeBackgroundColor, range: range)
            storage.addAttribute(.font, value: theme.codeFont, range: range)
            
            // Syntax Highlighting via Splash
            let code = (text as NSString).substring(with: range)
            let highlighted = highlighter.highlight(code)
            
            highlighted.enumerateAttributes(in: NSRange(location: 0, length: highlighted.length), options: []) { attrs, subRange, _ in
                let targetRange = NSRange(location: range.location + subRange.location, length: subRange.length)
                // We only care about foreground color from Splash
                if let color = attrs[.foregroundColor] as? NSColor {
                    storage.addAttribute(.foregroundColor, value: color, range: targetRange)
                }
            }
        }
    }
    
    mutating func visitBlockQuote(_ blockQuote: BlockQuote) {
        if let range = nsRange(from: blockQuote.range) {
            storage.addAttribute(.foregroundColor, value: theme.quoteColor, range: range)
            let italicFont = theme.baseFont.italic()
            storage.addAttribute(.font, value: italicFont, range: range)
        }
        descendInto(blockQuote)
    }
    
    mutating func visitLink(_ link: Link) {
        if let range = nsRange(from: link.range) {
            storage.addAttribute(.foregroundColor, value: theme.accentColor, range: range)
            storage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            if let destination = link.destination {
                storage.addAttribute(.link, value: destination, range: range)
            }
        }
        descendInto(link)
    }
    
    mutating func visitListItem(_ listItem: ListItem) {
        if let checkbox = listItem.checkbox {
            if let range = nsRange(from: listItem.range) {
                let isChecked = checkbox == .checked

                // Find the line containing this list item
                let fullText = storage.string as NSString
                let lineRange = fullText.lineRange(for: range)
                let line = fullText.substring(with: lineRange)

                // Find the checkbox pattern "- [ ]" or "- [x]"
                let checkboxPattern = #"^(\s*)- \[([ xX])\]( )?"#

                if let regex = try? NSRegularExpression(pattern: checkboxPattern, options: []),
                   let match = regex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.count)) {

                    // Calculate absolute position of the checkbox marker in the document
                    let checkboxAbsoluteRange = NSRange(
                        location: lineRange.location + match.range.location,
                        length: match.range.length
                    )

                    // Make the "- [ ]" or "- [x]" part transparent
                    storage.addAttribute(.foregroundColor, value: NSColor.clear, range: checkboxAbsoluteRange)

                    // Add a custom attribute to mark this as a checkbox location
                    storage.addAttribute(NSAttributedString.Key("isCheckbox"), value: isChecked, range: NSRange(location: checkboxAbsoluteRange.location, length: 1))

                    // Apply styling to the task text (text after the checkbox pattern)
                    let textStart = checkboxAbsoluteRange.location + checkboxAbsoluteRange.length
                    let textLength = (lineRange.location + lineRange.length) - textStart

                    if textLength > 0 && textStart + textLength <= storage.length {
                        let textRange = NSRange(location: textStart, length: textLength)

                        if isChecked {
                            storage.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: textRange)
                            storage.addAttribute(.foregroundColor, value: theme.secondaryColor, range: textRange)
                        }
                    }
                }
            }
        }
        descendInto(listItem)
    }
}

extension NSFont {
    func italic() -> NSFont {
        return NSFontManager.shared.convert(self, toHaveTrait: .italicFontMask)
    }

    func bold() -> NSFont {
        return NSFontManager.shared.convert(self, toHaveTrait: .boldFontMask)
    }
}