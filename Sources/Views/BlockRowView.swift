import SwiftUI

/// A row that renders a single block with appropriate view
struct BlockRowView: View {
    @Binding var block: Block

    var body: some View {
        Group {
            switch block {
            case .text(let id, let content):
                TextBlockView(
                    content: Binding(
                        get: { content },
                        set: { block = .text(id: id, content: $0) }
                    )
                )

            case .heading(let id, let level, let content):
                HeadingBlockView(
                    level: level,
                    content: Binding(
                        get: { content },
                        set: { block = .heading(id: id, level: level, content: $0) }
                    )
                )

            case .task(let id, let isChecked, let content):
                TaskBlockView(
                    isChecked: isChecked,
                    content: Binding(
                        get: { content },
                        set: { block = .task(id: id, isChecked: isChecked, content: $0) }
                    ),
                    onToggle: {
                        block = .task(id: id, isChecked: !isChecked, content: content)
                    }
                )

            case .bulletList(let id, let content):
                BulletListBlockView(
                    content: Binding(
                        get: { content },
                        set: { block = .bulletList(id: id, content: $0) }
                    )
                )

            case .codeBlock(let id, let language, let content):
                CodeBlockView(
                    language: language,
                    content: Binding(
                        get: { content },
                        set: { block = .codeBlock(id: id, language: language, content: $0) }
                    )
                )

            case .empty:
                EmptyBlockView()
            }
        }
    }
}
