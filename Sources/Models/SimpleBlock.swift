import Foundation

/// Simple text block
struct SimpleBlock: Identifiable, Equatable {
    let id: UUID
    var content: String

    init(id: UUID = UUID(), content: String = "") {
        self.id = id
        self.content = content
    }

    /// Checks if this block is a task (checkbox)
    var isTask: Bool {
        content.trimmingCharacters(in: .whitespaces).hasPrefix("- [ ]") ||
        content.trimmingCharacters(in: .whitespaces).hasPrefix("- [x]") ||
        content.trimmingCharacters(in: .whitespaces).hasPrefix("- [X]")
    }

    /// Returns true if the task is checked
    var isTaskChecked: Bool {
        content.trimmingCharacters(in: .whitespaces).hasPrefix("- [x]") ||
        content.trimmingCharacters(in: .whitespaces).hasPrefix("- [X]")
    }

    /// Returns the task text without the checkbox prefix (preserves trailing spaces)
    var taskText: String {
        // Don't trim! We want to preserve spaces at the end
        if content.hasPrefix("- [ ] ") {
            return String(content.dropFirst(6))
        } else if content.hasPrefix("- [x] ") || content.hasPrefix("- [X] ") {
            return String(content.dropFirst(6))
        }
        // Handle without space after bracket
        else if content.hasPrefix("- [ ]") {
            return String(content.dropFirst(5))
        } else if content.hasPrefix("- [x]") || content.hasPrefix("- [X]") {
            return String(content.dropFirst(5))
        }
        return content
    }

    /// Toggles the task state
    mutating func toggleTask() {
        let trimmed = content.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("- [ ]") {
            content = content.replacingOccurrences(of: "- [ ]", with: "- [x]")
        } else if trimmed.hasPrefix("- [x]") || trimmed.hasPrefix("- [X]") {
            content = content.replacingOccurrences(of: "- [x]", with: "- [ ]")
                              .replacingOccurrences(of: "- [X]", with: "- [ ]")
        }
    }
}
