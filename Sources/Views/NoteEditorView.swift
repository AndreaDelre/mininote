import SwiftUI

struct NoteEditorView: View {
    @EnvironmentObject var noteStore: NoteStore
    @EnvironmentObject var hotCornerManager: HotCornerManager
    @State private var editingContent: String = ""
    @FocusState private var isEditorFocused: Bool

    var body: some View {
        MarkdownEditorView(content: $editingContent)
            .focused($isEditorFocused)
            .padding(24) // Espace généreux pour le look minimaliste
            .onAppear {
                editingContent = noteStore.note.content
                isEditorFocused = true
            }
            .onChange(of: editingContent) { newValue in
                noteStore.updateContent(newValue)
            }
    }
}
