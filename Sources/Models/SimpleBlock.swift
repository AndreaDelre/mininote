import Foundation

/// Simple text block
struct SimpleBlock: Identifiable, Equatable {
    let id: UUID
    var content: String

    init(id: UUID = UUID(), content: String = "") {
        self.id = id
        self.content = content
    }
}
