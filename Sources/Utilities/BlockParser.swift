import Foundation

/// Parses markdown text into a list of blocks
class BlockParser {

    /// Parse markdown content into blocks
    static func parse(_ content: String) -> [Block] {
        var blocks: [Block] = []
        let lines = content.components(separatedBy: .newlines)

        var i = 0
        while i < lines.count {
            let line = lines[i]

            // Check for code block
            if line.hasPrefix("```") {
                let (codeBlock, endIndex) = parseCodeBlock(lines: lines, startIndex: i)
                blocks.append(codeBlock)
                i = endIndex
                continue
            }

            // Check for heading
            if line.hasPrefix("#") {
                blocks.append(parseHeading(line))
                i += 1
                continue
            }

            // Check for task
            if line.hasPrefix("- [") && (line.contains("- [ ]") || line.contains("- [x]") || line.contains("- [X]")) {
                blocks.append(parseTask(line))
                i += 1
                continue
            }

            // Check for bullet list
            if line.hasPrefix("- ") || line.hasPrefix("* ") || line.hasPrefix("+ ") {
                blocks.append(parseBulletList(line))
                i += 1
                continue
            }

            // Empty line
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                blocks.append(.empty(id: UUID()))
                i += 1
                continue
            }

            // Default: text block
            blocks.append(.text(id: UUID(), content: line))
            i += 1
        }

        return blocks
    }

    private static func parseHeading(_ line: String) -> Block {
        var level = 0
        var content = line

        // Count the number of # at the beginning
        for char in line {
            if char == "#" {
                level += 1
            } else if char == " " {
                break
            } else {
                break
            }
        }

        // Remove the # and leading space
        if level > 0 {
            let startIndex = line.index(line.startIndex, offsetBy: level)
            content = String(line[startIndex...]).trimmingCharacters(in: .whitespaces)
        }

        return .heading(id: UUID(), level: min(level, 6), content: content)
    }

    private static func parseTask(_ line: String) -> Block {
        // Pattern: "- [ ] content" or "- [x] content"
        let isChecked = line.contains("- [x]") || line.contains("- [X]")

        // Remove "- [ ] " or "- [x] "
        var content = line
        if let range = content.range(of: #"^- \[[ xX]\] "#, options: .regularExpression) {
            content.removeSubrange(range)
        }

        return .task(id: UUID(), isChecked: isChecked, content: content)
    }

    private static func parseBulletList(_ line: String) -> Block {
        // Remove "- ", "* ", or "+ " prefix
        var content = line
        if content.hasPrefix("- ") {
            content = String(content.dropFirst(2))
        } else if content.hasPrefix("* ") {
            content = String(content.dropFirst(2))
        } else if content.hasPrefix("+ ") {
            content = String(content.dropFirst(2))
        }

        return .bulletList(id: UUID(), content: content)
    }

    private static func parseCodeBlock(lines: [String], startIndex: Int) -> (Block, Int) {
        let firstLine = lines[startIndex]

        // Extract language if present (e.g., ```swift)
        let language = firstLine.count > 3 ? String(firstLine.dropFirst(3)).trimmingCharacters(in: .whitespaces) : nil

        // Find the closing ```
        var endIndex = startIndex + 1
        var codeContent: [String] = []

        while endIndex < lines.count {
            let line = lines[endIndex]
            if line.hasPrefix("```") {
                break
            }
            codeContent.append(line)
            endIndex += 1
        }

        let content = codeContent.joined(separator: "\n")
        let block = Block.codeBlock(id: UUID(), language: language, content: content)

        // Return the block and the index after the closing ```
        return (block, endIndex + 1)
    }

    /// Convert blocks back to markdown string
    static func blocksToMarkdown(_ blocks: [Block]) -> String {
        return blocks.map { $0.rawMarkdown }.joined(separator: "\n")
    }
}
