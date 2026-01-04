import SwiftUI

struct NoteEditorView: View {
    @EnvironmentObject var noteStore: NoteStore
    @EnvironmentObject var hotCornerManager: HotCornerManager

    var body: some View {
        SimpleBlockEditor(content: $noteStore.note.content)
    }
}
