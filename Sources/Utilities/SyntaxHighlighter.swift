import AppKit
import Splash

class CodeSyntaxHighlighter {
    
    private let highlighter: Splash.SyntaxHighlighter<AttributedStringOutputFormat>
    
    init() {
        let theme = Theme(
            font: Font(size: 14),
            plainTextColor: .labelColor,
            tokenColors: [
                .keyword: .systemPink,
                .string: .systemRed,
                .type: .systemTeal,
                .call: .systemPurple,
                .number: .systemBlue,
                .comment: .secondaryLabelColor,
                .property: .systemGreen,
                .dotAccess: .labelColor,
                .preprocessing: .systemOrange
            ]
        )
        self.highlighter = Splash.SyntaxHighlighter(format: AttributedStringOutputFormat(theme: theme))
    }
    
    func highlight(_ code: String) -> NSAttributedString {
        return highlighter.highlight(code)
    }
}

struct AttributedStringOutputFormat: OutputFormat {
    let theme: Theme
    
    func makeBuilder() -> Builder {
        return Builder(theme: theme)
    }
}

extension AttributedStringOutputFormat {
    struct Builder: OutputBuilder {
        let theme: Theme
        private var attributedString = NSMutableAttributedString()
        
        init(theme: Theme) {
            self.theme = theme
        }
        
        mutating func addToken(_ token: String, ofType type: TokenType) {
            let color = theme.tokenColors[type] ?? theme.plainTextColor
            let font = NSFont.monospacedSystemFont(ofSize: CGFloat(theme.font.size), weight: .regular)
            let attr = NSAttributedString(string: token, attributes: [.foregroundColor: color, .font: font])
            attributedString.append(attr)
        }
        
        mutating func addPlainText(_ text: String) {
            let font = NSFont.monospacedSystemFont(ofSize: CGFloat(theme.font.size), weight: .regular)
            let attr = NSAttributedString(string: text, attributes: [.foregroundColor: theme.plainTextColor, .font: font])
            attributedString.append(attr)
        }
        
        mutating func addWhitespace(_ whitespace: String) {
            let font = NSFont.monospacedSystemFont(ofSize: CGFloat(theme.font.size), weight: .regular)
            let attr = NSAttributedString(string: whitespace, attributes: [.foregroundColor: theme.plainTextColor, .font: font])
            attributedString.append(attr)
        }
        
        func build() -> NSAttributedString {
            return attributedString
        }
    }
}