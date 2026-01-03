import SwiftUI

struct NoteEditorView: View {
    @EnvironmentObject var noteStore: NoteStore
    @EnvironmentObject var hotCornerManager: HotCornerManager
    @State private var editingContent: String = ""
    @FocusState private var isEditorFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("MiniNote")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Spacer()

                Button(action: {
                    hotCornerManager.isNoteVisible = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))

            Divider()

            MarkdownEditorView(content: $editingContent)
                .focused($isEditorFocused)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            editingContent = noteStore.note.content
            isEditorFocused = true
        }
        .onChange(of: editingContent) { newValue in
            noteStore.updateContent(newValue)
        }
    }
}
