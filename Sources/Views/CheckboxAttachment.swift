import AppKit

/// A custom NSTextAttachment that renders a visual checkbox in the text view
class CheckboxAttachment: NSTextAttachment {
    var isChecked: Bool
    private let checkboxSize: CGFloat = 16
    private let borderWidth: CGFloat = 1.5

    init(isChecked: Bool) {
        self.isChecked = isChecked
        super.init(data: nil, ofType: nil)
    }

    required init?(coder: NSCoder) {
        self.isChecked = false
        super.init(coder: coder)
    }

    override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        // Position the checkbox aligned with the text baseline
        return CGRect(x: 0, y: -2, width: checkboxSize, height: checkboxSize)
    }

    override func image(forBounds imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> NSImage? {
        let image = NSImage(size: CGSize(width: checkboxSize, height: checkboxSize))

        image.lockFocus()

        // Draw the checkbox
        let rect = CGRect(x: borderWidth/2, y: borderWidth/2,
                         width: checkboxSize - borderWidth,
                         height: checkboxSize - borderWidth)

        let path = NSBezierPath(roundedRect: rect, xRadius: 3, yRadius: 3)

        // Background and border
        if isChecked {
            NSColor.systemBlue.setFill()
            path.fill()
        } else {
            NSColor.clear.setFill()
            path.fill()
        }

        NSColor.tertiaryLabelColor.setStroke()
        path.lineWidth = borderWidth
        path.stroke()

        // Draw checkmark if checked
        if isChecked {
            let checkPath = NSBezierPath()
            let checkSize = checkboxSize * 0.6
            let offsetX = (checkboxSize - checkSize) / 2
            let offsetY = (checkboxSize - checkSize) / 2

            // Checkmark path
            checkPath.move(to: CGPoint(x: offsetX + checkSize * 0.2, y: offsetY + checkSize * 0.5))
            checkPath.line(to: CGPoint(x: offsetX + checkSize * 0.4, y: offsetY + checkSize * 0.3))
            checkPath.line(to: CGPoint(x: offsetX + checkSize * 0.8, y: offsetY + checkSize * 0.7))

            NSColor.white.setStroke()
            checkPath.lineWidth = 2
            checkPath.lineCapStyle = .round
            checkPath.lineJoinStyle = .round
            checkPath.stroke()
        }

        image.unlockFocus()

        return image
    }
}

/// Extension to help identify checkbox attachments
extension NSTextAttachment {
    var isCheckboxAttachment: Bool {
        return self is CheckboxAttachment
    }

    var checkboxAttachment: CheckboxAttachment? {
        return self as? CheckboxAttachment
    }
}
