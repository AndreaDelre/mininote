import Foundation

/// Represents a block of content in the markdown editor
enum Block: Identifiable, Equatable {
    case text(id: UUID, content: String)
    case heading(id: UUID, level: Int, content: String)
    case task(id: UUID, isChecked: Bool, content: String)
    case bulletList(id: UUID, content: String)
    case codeBlock(id: UUID, language: String?, content: String)
    case empty(id: UUID)

    var id: UUID {
        switch self {
        case .text(let id, _),
             .heading(let id, _, _),
             .task(let id, _, _),
             .bulletList(let id, _),
             .codeBlock(let id, _, _),
             .empty(let id):
            return id
        }
    }

    /// Returns the raw markdown representation of this block
    var rawMarkdown: String {
        switch self {
        case .text(_, let content):
            return content
        case .heading(_, let level, let content):
            return String(repeating: "#", count: level) + " " + content
        case .task(_, let isChecked, let content):
            return "- [\(isChecked ? "x" : " ")] " + content
        case .bulletList(_, let content):
            return "- " + content
        case .codeBlock(_, let language, let content):
            let lang = language ?? ""
            return "```\(lang)\n\(content)\n```"
        case .empty:
            return ""
        }
    }
}
