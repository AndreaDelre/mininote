import Foundation

struct Note: Codable, Identifiable {
    let id: UUID
    var content: String
    var lastModified: Date

    init(id: UUID = UUID(), content: String = "", lastModified: Date = Date()) {
        self.id = id
        self.content = content
        self.lastModified = lastModified
    }
}
