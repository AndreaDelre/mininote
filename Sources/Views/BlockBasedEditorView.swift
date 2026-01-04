import SwiftUI

/// Block-based markdown editor using SwiftUI
struct BlockBasedEditorView: View {
    @Binding var content: String
    @State private var blocks: [Block] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach($blocks) { $block in
                    BlockRowView(block: $block)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            parseContent()
        }
        .onChange(of: blocks) { _ in
            // Update content when blocks change
            content = BlockParser.blocksToMarkdown(blocks)
        }
    }

    private func parseContent() {
        blocks = BlockParser.parse(content)
    }
}
