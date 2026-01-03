import Foundation
import Combine

class NoteStore: ObservableObject {
    @Published var note: Note

    private let saveDebouncer = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()

    private var saveURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = appSupport.appendingPathComponent("MiniNote", isDirectory: true)
        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        return appDir.appendingPathComponent("note.json")
    }

    init() {
        self.note = Self.loadNote()

        saveDebouncer
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.saveNote()
            }
            .store(in: &cancellables)

        $note
            .dropFirst()
            .sink { [weak self] _ in
                self?.saveDebouncer.send()
            }
            .store(in: &cancellables)
    }

    private static func loadNote() -> Note {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = appSupport.appendingPathComponent("MiniNote", isDirectory: true)
        let url = appDir.appendingPathComponent("note.json")

        guard let data = try? Data(contentsOf: url),
              let note = try? JSONDecoder().decode(Note.self, from: data) else {
            return Note(content: "# My Notes\n\n- [ ] First task\n- [ ] Second task")
        }

        return note
    }

    private func saveNote() {
        var updatedNote = note
        updatedNote.lastModified = Date()

        if let data = try? JSONEncoder().encode(updatedNote) {
            try? data.write(to: saveURL)
        }
    }

    func updateContent(_ newContent: String) {
        note.content = newContent
    }
}
