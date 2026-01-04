import SwiftUI

/// Simple block-based editor - starts with just text blocks
struct SimpleEditorView: View {
    @Binding var content: String
    @State private var blocks: [SimpleBlock] = []
    @FocusState private var focusedBlockId: UUID?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach($blocks) { $block in
                    SimpleBlockView(
                        block: $block,
                        isFocused: focusedBlockId == block.id,
                        onEnter: {
                            createNewBlockAfter(block.id)
                        },
                        onBackspaceAtStart: {
                            mergeWithPrevious(block.id)
                        }
                    )
                    .focused($focusedBlockId, equals: block.id)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
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
        // Split content by newlines to create initial blocks
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

    private func createNewBlockAfter(_ blockId: UUID) {
        guard let index = blocks.firstIndex(where: { $0.id == blockId }) else { return }

        let newBlock = SimpleBlock(content: "")
        blocks.insert(newBlock, at: index + 1)

        // Focus the new block
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            focusedBlockId = newBlock.id
        }
    }

    private func mergeWithPrevious(_ blockId: UUID) {
        guard let index = blocks.firstIndex(where: { $0.id == blockId }), index > 0 else { return }

        let currentBlock = blocks[index]
        let previousIndex = index - 1

        // Merge content with previous block
        blocks[previousIndex].content += currentBlock.content

        // Remove current block
        blocks.remove(at: index)

        // Focus previous block
        focusedBlockId = blocks[previousIndex].id
    }
}

/// Simple text block view with custom key handling
struct SimpleBlockView: View {
    @Binding var block: SimpleBlock
    let isFocused: Bool
    let onEnter: () -> Void
    let onBackspaceAtStart: () -> Void

    var body: some View {
        CustomTextField(
            text: $block.content,
            onEnter: onEnter,
            onBackspaceAtStart: onBackspaceAtStart
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 2)
    }
}

/// Custom NSTextField that handles Enter and Backspace
struct CustomTextField: NSViewRepresentable {
    @Binding var text: String
    let onEnter: () -> Void
    let onBackspaceAtStart: () -> Void

    func makeNSView(context: Context) -> NSTextField {
        let textField = CustomNSTextField()
        textField.delegate = context.coordinator
        textField.isBordered = false
        textField.isBezeled = false
        textField.drawsBackground = false
        textField.font = .systemFont(ofSize: 15)
        textField.focusRingType = .none
        textField.lineBreakMode = .byWordWrapping
        textField.usesSingleLineMode = false
        textField.maximumNumberOfLines = 0
        textField.cell?.wraps = true
        textField.cell?.isScrollable = false

        textField.onEnter = onEnter
        textField.onBackspaceAtStart = onBackspaceAtStart

        return textField
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    class Coordinator: NSObject, NSTextFieldDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func controlTextDidChange(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            text = textField.stringValue
        }
    }
}

/// Custom NSTextField that intercepts key events
class CustomNSTextField: NSTextField {
    var onEnter: (() -> Void)?
    var onBackspaceAtStart: (() -> Void)?

    override func keyDown(with event: NSEvent) {
        // Handle Enter key
        if event.keyCode == 36 { // Enter/Return key
            onEnter?()
            return
        }

        // Handle Backspace at start
        if event.keyCode == 51 { // Delete/Backspace key
            if stringValue.isEmpty {
                onBackspaceAtStart?()
                return
            }
        }

        super.keyDown(with: event)
    }

    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()

        // Move cursor to end instead of selecting all
        if result, let editor = currentEditor() as? NSTextView {
            editor.selectedRange = NSRange(location: stringValue.count, length: 0)
        }

        return result
    }

    override func textDidBeginEditing(_ notification: Notification) {
        super.textDidBeginEditing(notification)

        // Ensure cursor is at end when beginning edit
        if let editor = currentEditor() as? NSTextView {
            editor.selectedRange = NSRange(location: stringValue.count, length: 0)
        }
    }
}
