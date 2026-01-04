import SwiftUI
import AppKit

/// Simple block editor with proper Enter and Backspace handling
struct SimpleBlockEditor: View {
    @Binding var content: String
    @State private var blocks: [SimpleBlock] = []
    @FocusState private var focusedBlockId: UUID?
    @State private var desiredCursorPosition: Int? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach($blocks) { $block in
                    BlockTextView(
                        block: $block,
                        isFocused: focusedBlockId == block.id,
                        desiredCursorPosition: focusedBlockId == block.id ? desiredCursorPosition : nil,
                        onSplit: { textBefore, textAfter in
                            splitBlock(block.id, textBefore: textBefore, textAfter: textAfter)
                        },
                        onBackspaceAtStart: {
                            mergeWithPrevious(block.id)
                        }
                    )
                    .focused($focusedBlockId, equals: block.id)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            loadContent()
        }
        .onChange(of: blocks) { _ in
            saveContent()
        }
    }

    private func loadContent() {
        let lines = content.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)

        if lines.isEmpty {
            blocks = [SimpleBlock(content: "")]
        } else {
            blocks = lines.map { SimpleBlock(content: $0) }
        }

        // Focus first block
        if let firstId = blocks.first?.id {
            focusedBlockId = firstId
        }
    }

    private func saveContent() {
        content = blocks.map { $0.content }.joined(separator: "\n")
    }

    private func splitBlock(_ blockId: UUID, textBefore: String, textAfter: String) {
        guard let index = blocks.firstIndex(where: { $0.id == blockId }) else {
            return
        }

        // Update current block with text before cursor
        blocks[index].content = textBefore

        // Create new block with text after cursor
        let newBlock = SimpleBlock(content: textAfter)
        blocks.insert(newBlock, at: index + 1)

        // Set cursor at beginning of new block (position 0)
        desiredCursorPosition = 0

        // Focus the new block immediately (no delay)
        focusedBlockId = newBlock.id

        // Clear desired cursor position after the view updates
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            desiredCursorPosition = nil
        }
    }

    private func mergeWithPrevious(_ blockId: UUID) {
        guard let index = blocks.firstIndex(where: { $0.id == blockId }), index > 0 else { return }

        let currentBlock = blocks[index]
        let previousIndex = index - 1

        // Store the cursor position (should be at the junction)
        let cursorPosition = blocks[previousIndex].content.count

        // Merge content with previous block
        blocks[previousIndex].content += currentBlock.content

        // Remove current block
        blocks.remove(at: index)

        // Set desired cursor position
        desiredCursorPosition = cursorPosition

        // Focus previous block
        focusedBlockId = blocks[previousIndex].id

        // Clear desired cursor position after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            desiredCursorPosition = nil
        }
    }
}

/// Simple text block view with custom key handling
struct BlockTextView: View {
    @Binding var block: SimpleBlock
    let isFocused: Bool
    let desiredCursorPosition: Int?
    let onSplit: (String, String) -> Void
    let onBackspaceAtStart: () -> Void

    var body: some View {
        BlockTextField(
            text: $block.content,
            desiredCursorPosition: desiredCursorPosition,
            onSplit: onSplit,
            onBackspaceAtStart: onBackspaceAtStart
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.2))
        .padding(.vertical, 2)
    }
}

/// Custom NSTextView wrapper that handles Enter and Backspace
struct BlockTextField: NSViewRepresentable {
    @Binding var text: String
    let desiredCursorPosition: Int?
    let onSplit: (String, String) -> Void
    let onBackspaceAtStart: () -> Void

    func makeNSView(context: Context) -> CustomTextView {
        let textView = CustomTextView()
        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.isEditable = true
        textView.isSelectable = true
        textView.font = .systemFont(ofSize: 15)
        textView.textColor = .labelColor
        textView.drawsBackground = false
        textView.backgroundColor = .clear
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.textContainer?.lineFragmentPadding = 0
        textView.textContainerInset = NSSize(width: 0, height: 0)

        // Configure text container for proper wrapping
        if let container = textView.textContainer {
            container.widthTracksTextView = true
            container.containerSize = NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
        }

        // Store callbacks in coordinator
        context.coordinator.onSplit = onSplit
        context.coordinator.onBackspaceAtStart = onBackspaceAtStart

        return textView
    }

    func updateNSView(_ nsView: CustomTextView, context: Context) {
        if nsView.string != text {
            nsView.string = text
            // Force layout recalculation after text change
            nsView.invalidateIntrinsicContentSize()
            nsView.layoutManager?.ensureLayout(for: nsView.textContainer!)
        }

        // Update callbacks in coordinator
        context.coordinator.onSplit = onSplit
        context.coordinator.onBackspaceAtStart = onBackspaceAtStart

        // Set cursor position if specified
        if let position = desiredCursorPosition {
            let clampedPosition = min(position, nsView.string.count)
            nsView.setSelectedRange(NSRange(location: clampedPosition, length: 0))
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        @Binding var text: String
        var onSplit: (String, String) -> Void
        var onBackspaceAtStart: () -> Void

        init(text: Binding<String>) {
            _text = text
            self.onSplit = { _, _ in }
            self.onBackspaceAtStart = { }
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            text = textView.string
        }

        func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                // Enter key pressed
                let cursorPosition = textView.selectedRange().location
                let fullText = textView.string

                let textBefore = String(fullText.prefix(cursorPosition))
                let textAfter = String(fullText.suffix(fullText.count - cursorPosition))

                onSplit(textBefore, textAfter)
                return true // Handled
            }

            if commandSelector == #selector(NSResponder.deleteBackward(_:)) {
                // Backspace pressed
                let cursorPosition = textView.selectedRange().location

                // If cursor is at the very beginning (position 0), merge with previous block
                if cursorPosition == 0 {
                    onBackspaceAtStart()
                    return true // Handled
                }
            }

            return false // Not handled, continue normal processing
        }
    }
}

/// Custom NSTextView that properly calculates its intrinsic content size
class CustomTextView: NSTextView {
    override var intrinsicContentSize: NSSize {
        guard let layoutManager = layoutManager,
              let textContainer = textContainer else {
            return super.intrinsicContentSize
        }

        layoutManager.ensureLayout(for: textContainer)
        let usedRect = layoutManager.usedRect(for: textContainer)

        return NSSize(
            width: NSView.noIntrinsicMetric,
            height: max(usedRect.height, 20)
        )
    }

    override func didChangeText() {
        super.didChangeText()
        invalidateIntrinsicContentSize()
    }
}
