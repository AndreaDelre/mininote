import SwiftUI
import AppKit

/// Simple block editor with proper Enter and Backspace handling
struct SimpleBlockEditor: View {
    @Binding var content: String
    @State private var blocks: [SimpleBlock] = []
    @FocusState private var focusedBlockId: UUID?
    @State private var desiredCursorPosition: Int? = nil
    @State private var updateTrigger: Int = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach($blocks) { $block in
                    UnifiedBlockView(
                        block: $block,
                        isFocused: focusedBlockId == block.id,
                        desiredCursorPosition: focusedBlockId == block.id ? desiredCursorPosition : nil,
                        shouldPreventSplit: block.isCodeBlock && !block.isCodeBlockClosed,
                        onSplit: { textBefore, textAfter in
                            splitBlock(block.id, textBefore: textBefore, textAfter: textAfter)
                        },
                        onBackspaceAtStart: {
                            mergeWithPrevious(block.id)
                        },
                        onArrowUp: { cursorPosition in
                            moveToPreviousBlock(block.id, cursorPosition: cursorPosition)
                        },
                        onArrowDown: { cursorPosition in
                            moveToNextBlock(block.id, cursorPosition: cursorPosition)
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
            updateTrigger += 1
        }
    }

    private func loadContent() {
        let lines = content.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)

        if lines.isEmpty {
            blocks = [SimpleBlock(content: "")]
        } else {
            // Parse lines and group code blocks together
            var parsedBlocks: [SimpleBlock] = []
            var i = 0

            while i < lines.count {
                let line = lines[i]
                let trimmed = line.trimmingCharacters(in: .whitespaces)

                // Check if this line starts a code block
                if trimmed.hasPrefix("```") {
                    // Accumulate lines until we find closing ```
                    var codeBlockLines = [line]
                    i += 1
                    var foundClosing = false

                    while i < lines.count {
                        let nextLine = lines[i]
                        codeBlockLines.append(nextLine)

                        let trimmedNext = nextLine.trimmingCharacters(in: .whitespaces)
                        if trimmedNext == "```" || trimmedNext.hasSuffix("```") {
                            foundClosing = true
                            i += 1
                            break
                        }
                        i += 1
                    }

                    // Create a single block with all code lines
                    let codeBlockContent = codeBlockLines.joined(separator: "\n")
                    parsedBlocks.append(SimpleBlock(content: codeBlockContent))
                } else {
                    // Regular line - create a block
                    parsedBlocks.append(SimpleBlock(content: line))
                    i += 1
                }
            }

            blocks = parsedBlocks
        }

        // Log all block IDs to check for duplicates
        let ids = blocks.map { $0.id }
        let uniqueIds = Set(ids)
        if ids.count != uniqueIds.count {
            print("⚠️ DUPLICATE BLOCK IDs DETECTED!")
            for id in ids {
                print("  ID: \(id)")
            }
        } else {
            print("✅ All block IDs are unique (\(ids.count) blocks)")
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

    private func moveToPreviousBlock(_ blockId: UUID, cursorPosition: Int) {
        guard let index = blocks.firstIndex(where: { $0.id == blockId }), index > 0 else { return }

        let previousIndex = index - 1
        let previousBlockLength = blocks[previousIndex].content.count

        // Set cursor position to the same column, but clamped to the previous block's length
        desiredCursorPosition = min(cursorPosition, previousBlockLength)

        // Focus the previous block
        focusedBlockId = blocks[previousIndex].id

        // Clear desired cursor position after the view updates
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            desiredCursorPosition = nil
        }
    }

    private func moveToNextBlock(_ blockId: UUID, cursorPosition: Int) {
        guard let index = blocks.firstIndex(where: { $0.id == blockId }), index < blocks.count - 1 else { return }

        let nextIndex = index + 1
        let nextBlockLength = blocks[nextIndex].content.count

        // Set cursor position to the same column, but clamped to the next block's length
        desiredCursorPosition = min(cursorPosition, nextBlockLength)

        // Focus the next block
        focusedBlockId = blocks[nextIndex].id

        // Clear desired cursor position after the view updates
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
    let onArrowUp: (Int) -> Void
    let onArrowDown: (Int) -> Void

    var body: some View {
        BlockTextField(
            text: $block.content,
            desiredCursorPosition: desiredCursorPosition,
            shouldPreventSplit: block.isCodeBlock && !block.isCodeBlockClosed,
            onSplit: onSplit,
            onBackspaceAtStart: onBackspaceAtStart,
            onArrowUp: onArrowUp,
            onArrowDown: onArrowDown
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
    let shouldPreventSplit: Bool
    let onSplit: (String, String) -> Void
    let onBackspaceAtStart: () -> Void
    let onArrowUp: (Int) -> Void
    let onArrowDown: (Int) -> Void

    func makeNSView(context: Context) -> CustomTextView {
        let textView = CustomTextView()
        textView.delegate = context.coordinator
        textView.isRichText = true // Must be true for markdown styling
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

        // Store callbacks and settings in coordinator
        context.coordinator.shouldPreventSplit = shouldPreventSplit
        context.coordinator.onSplit = onSplit
        context.coordinator.onBackspaceAtStart = onBackspaceAtStart
        context.coordinator.onArrowUp = onArrowUp
        context.coordinator.onArrowDown = onArrowDown

        return textView
    }

    func updateNSView(_ nsView: CustomTextView, context: Context) {
        // Only update text if the change came from outside (not from user typing)
        if !context.coordinator.isUpdatingFromTextView && nsView.string != text {
            nsView.string = text
            // Force markdown styling on text change
            nsView.applyMarkdownStyling()
            // Force layout recalculation after text change
            nsView.invalidateIntrinsicContentSize()
            nsView.layoutManager?.ensureLayout(for: nsView.textContainer!)
        }

        // Update callbacks and settings in coordinator
        context.coordinator.shouldPreventSplit = shouldPreventSplit
        context.coordinator.onSplit = onSplit
        context.coordinator.onBackspaceAtStart = onBackspaceAtStart
        context.coordinator.onArrowUp = onArrowUp
        context.coordinator.onArrowDown = onArrowDown

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
        var shouldPreventSplit: Bool = false
        var onSplit: (String, String) -> Void
        var onBackspaceAtStart: () -> Void
        var onArrowUp: (Int) -> Void
        var onArrowDown: (Int) -> Void
        var isUpdatingFromTextView = false

        init(text: Binding<String>) {
            _text = text
            self.onSplit = { _, _ in }
            self.onBackspaceAtStart = { }
            self.onArrowUp = { _ in }
            self.onArrowDown = { _ in }
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }

            let currentText = textView.string

            isUpdatingFromTextView = true
            text = currentText
            isUpdatingFromTextView = false
        }

        func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                // Enter key pressed
                let cursorPosition = textView.selectedRange().location
                let fullText = textView.string
                let trimmed = fullText.trimmingCharacters(in: .whitespaces)

                // Check if this is a code block (starts with ```)
                if trimmed.hasPrefix("```") {
                    // Check if cursor is at the very end of the block
                    let textAfter = String(fullText.suffix(fullText.count - cursorPosition))
                    let trimmedAfter = textAfter.trimmingCharacters(in: .whitespaces)

                    // If there's content after cursor (not at end), allow normal newline
                    if !trimmedAfter.isEmpty {
                        return false // Let NSTextView handle newline normally
                    }

                    // Cursor is at the end - check if block is properly closed
                    // Must: start with ```, end with ```, have at least 6 backticks total
                    let backtickCount = fullText.filter { $0 == "`" }.count
                    if trimmed.hasPrefix("```") && trimmed.hasSuffix("```") && backtickCount >= 6 {
                        // Valid closed code block at end - allow split
                        let textBefore = String(fullText.prefix(cursorPosition))
                        let textAfter = String(fullText.suffix(fullText.count - cursorPosition))
                        onSplit(textBefore, textAfter)
                        return true // Handled
                    }

                    // Code block not properly closed or not at end - normal newline
                    return false // Let NSTextView handle newline normally
                }

                // Not a code block - normal split behavior
                let textBefore = String(fullText.prefix(cursorPosition))
                let textAfter = String(fullText.suffix(fullText.count - cursorPosition))

                onSplit(textBefore, textAfter)
                return true // Handled
            }

            if commandSelector == #selector(NSResponder.deleteBackward(_:)) {
                // Backspace pressed
                let selectedRange = textView.selectedRange()
                let cursorPosition = selectedRange.location
                let hasSelection = selectedRange.length > 0

                // Only merge if cursor is at position 0 AND nothing is selected
                // If text is selected, let normal delete behavior happen
                if cursorPosition == 0 && !hasSelection {
                    onBackspaceAtStart()
                    return true // Handled
                }
            }

            if commandSelector == #selector(NSResponder.moveUp(_:)) {
                // Up arrow pressed - always move to previous block if on first line
                let cursorPosition = textView.selectedRange().location
                let text = textView.string

                // Check if cursor is on the first line (no newline before cursor)
                let textBeforeCursor = text.prefix(cursorPosition)
                let isOnFirstLine = !textBeforeCursor.contains("\n")

                if isOnFirstLine {
                    onArrowUp(cursorPosition)
                    return true // Handled
                }
            }

            if commandSelector == #selector(NSResponder.moveDown(_:)) {
                // Down arrow pressed - always move to next block if on last line
                let cursorPosition = textView.selectedRange().location
                let text = textView.string

                // Check if cursor is on the last line (no newline after cursor)
                let textAfterCursor = text.suffix(text.count - cursorPosition)
                let isOnLastLine = !textAfterCursor.contains("\n")

                if isOnLastLine {
                    onArrowDown(cursorPosition)
                    return true // Handled
                }
            }

            return false // Not handled, continue normal processing
        }
    }
}

/// Custom NSTextView that properly calculates its intrinsic content size and applies markdown styling
class CustomTextView: NSTextView {
    private let markdownParser = MarkdownParser()

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

        // Apply markdown styling
        applyMarkdownStyling()
    }

    func applyMarkdownStyling() {
        guard let textStorage = textStorage else {
            print("❌ No textStorage available")
            return
        }

        print("📝 Applying markdown styling to: '\(textStorage.string)'")

        // Save cursor position
        let selectedRange = self.selectedRange()

        // Apply markdown parsing with safety
        do {
            markdownParser.parseAndApply(to: textStorage)
        } catch {
            print("⚠️ Markdown parsing error: \(error)")
            // Don't crash, just skip styling for this update
        }

        // Log attributes after parsing
        if textStorage.length > 0 {
            let attrs = textStorage.attributes(at: 0, effectiveRange: nil)
            print("✅ Attributes applied: \(attrs)")
        }

        // Restore cursor position safely
        let safeRange = NSRange(
            location: min(selectedRange.location, textStorage.length),
            length: min(selectedRange.length, textStorage.length - min(selectedRange.location, textStorage.length))
        )
        self.setSelectedRange(safeRange)
    }
}

/// Checkbox block view with SwiftUI checkbox and text editor
struct CheckboxBlockView: View {
    @Binding var block: SimpleBlock
    let isFocused: Bool
    let desiredCursorPosition: Int?
    let onSplit: (String, String) -> Void
    let onBackspaceAtStart: () -> Void
    let onArrowUp: (Int) -> Void
    let onArrowDown: (Int) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // SwiftUI Checkbox
            Toggle("", isOn: Binding(
                get: { block.isTaskChecked },
                set: { _ in block.toggleTask() }
            ))
            .toggleStyle(.checkbox)
            .labelsHidden()
            .padding(.top, 2)

            // Text editor (only the task text, without "- [ ]")
            BlockTextField(
                text: Binding(
                    get: { block.taskText },
                    set: { newText in
                        // Keep the checkbox prefix, update only the text part
                        let prefix = block.isTaskChecked ? "- [x] " : "- [ ] "
                        block.content = prefix + newText
                    }
                ),
                desiredCursorPosition: desiredCursorPosition,
                shouldPreventSplit: false, // Tasks don't prevent split
                onSplit: { textBefore, textAfter in
                    // When splitting, add the checkbox prefix back
                    let prefix = block.isTaskChecked ? "- [x] " : "- [ ] "
                    onSplit(prefix + textBefore, textAfter)
                },
                onBackspaceAtStart: onBackspaceAtStart,
                onArrowUp: onArrowUp,
                onArrowDown: onArrowDown
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.2))
        .padding(.vertical, 2)
    }
}

/// Unified block view that handles both regular text and tasks
struct UnifiedBlockView: View {
    @Binding var block: SimpleBlock
    let isFocused: Bool
    let desiredCursorPosition: Int?
    let shouldPreventSplit: Bool
    let onSplit: (String, String) -> Void
    let onBackspaceAtStart: () -> Void
    let onArrowUp: (Int) -> Void
    let onArrowDown: (Int) -> Void

    @State private var showCheckbox: Bool = false

    var body: some View {
        let _ = print("🔄 UnifiedBlockView render: '\(block.content)' isTask=\(block.isTask) showCheckbox=\(showCheckbox)")

        HStack(alignment: .top, spacing: 8) {
            // Show checkbox only if it's a task
            if showCheckbox {
                Toggle("", isOn: Binding(
                    get: { block.isTaskChecked },
                    set: { _ in block.toggleTask() }
                ))
                .toggleStyle(.checkbox)
                .labelsHidden()
                .padding(.top, 2)
            }

            // Text editor
            BlockTextField(
                text: Binding(
                    get: {
                        // If checkbox is shown, display only the text without the prefix
                        if showCheckbox {
                            return block.taskText
                        } else {
                            return block.content
                        }
                    },
                    set: { newText in
                        print("⌨️ TextField set: '\(newText)' showCheckbox=\(showCheckbox)")
                        if showCheckbox {
                            // Keep the checkbox prefix
                            let prefix = block.isTaskChecked ? "- [x] " : "- [ ] "
                            block.content = prefix + newText
                        } else {
                            block.content = newText
                        }
                        print("   → block.content now: '\(block.content)'")
                    }
                ),
                desiredCursorPosition: showCheckbox ? nil : desiredCursorPosition,
                shouldPreventSplit: shouldPreventSplit,
                onSplit: { textBefore, textAfter in
                    if showCheckbox {
                        // Add prefix back when splitting
                        let prefix = block.isTaskChecked ? "- [x] " : "- [ ] "
                        onSplit(prefix + textBefore, textAfter)
                    } else {
                        onSplit(textBefore, textAfter)
                    }
                },
                onBackspaceAtStart: {
                    if showCheckbox {
                        // When at start of task text, remove the checkbox to go back to normal text
                        block.content = block.taskText
                        showCheckbox = false
                    } else {
                        onBackspaceAtStart()
                    }
                },
                onArrowUp: onArrowUp,
                onArrowDown: onArrowDown
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.2))
        .padding(.vertical, 2)
        .onAppear {
            showCheckbox = block.isTask
        }
        .onChange(of: block.content) { _ in
            withAnimation(.none) {
                showCheckbox = block.isTask
            }
        }
    }
}
