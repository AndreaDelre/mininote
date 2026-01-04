import SwiftUI

// MARK: - Task Block View with Interactive Checkbox

struct TaskBlockView: View {
    let isChecked: Bool
    @Binding var content: String
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Custom checkbox button
            Button(action: onToggle) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1.5)
                        .frame(width: 18, height: 18)

                    if isChecked {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.blue)
                            .frame(width: 18, height: 18)

                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            .frame(width: 18, height: 18)
            .padding(.top, 2)

            // Editable text
            TextField("", text: $content)
            .textFieldStyle(PlainTextFieldStyle())
            .font(.system(size: 15))
            .foregroundColor(isChecked ? .secondary : .primary)
            .strikethrough(isChecked, color: .secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Text Block View

struct TextBlockView: View {
    @Binding var content: String

    var body: some View {
        TextField("", text: $content)
        .textFieldStyle(PlainTextFieldStyle())
        .font(.system(size: 15))
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 2)
    }
}

// MARK: - Heading Block View

struct HeadingBlockView: View {
    let level: Int
    @Binding var content: String

    var fontSize: CGFloat {
        switch level {
        case 1: return 26
        case 2: return 20
        case 3: return 17
        default: return 15
        }
    }

    var body: some View {
        TextField("", text: $content)
        .textFieldStyle(PlainTextFieldStyle())
        .font(.system(size: fontSize, weight: .bold))
        .foregroundColor(level == 1 ? .blue : .primary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, level == 1 ? 4 : 2)
    }
}

// MARK: - Bullet List Block View

struct BulletListBlockView: View {
    @Binding var content: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .padding(.top, 2)

            TextField("", text: $content)
            .textFieldStyle(PlainTextFieldStyle())
            .font(.system(size: 15))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Code Block View

struct CodeBlockView: View {
    let language: String?
    @Binding var content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let language = language, !language.isEmpty {
                Text(language)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.top, 4)
            }

            TextEditor(text: $content)
                .font(.system(size: 14, design: .monospaced))
                .frame(minHeight: 60)
                .padding(8)
        }
        .background(Color.black.opacity(0.05))
        .cornerRadius(6)
        .padding(.vertical, 4)
    }
}

// MARK: - Empty Block View

struct EmptyBlockView: View {
    var body: some View {
        Text("")
            .frame(height: 20)
    }
}
