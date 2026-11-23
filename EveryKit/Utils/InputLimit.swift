import SwiftUI

enum InputLimit {
    /// 1 МиБ. Ограничение именно по UTF-8 байтам, чтобы кириллица и эмодзи не обходили лимит.
    static let maxTextBytes = 1_048_576
    static let maxImageBytes = 20 * 1_048_576

    static func truncated(_ text: String, limit: Int = maxTextBytes) -> String {
        guard text.utf8.count > limit else { return text }

        var result = ""
        var bytes = 0
        result.reserveCapacity(limit)
        for scalar in text.unicodeScalars {
            let size = scalar.utf8.count
            guard bytes + size <= limit else { break }
            result.unicodeScalars.append(scalar)
            bytes += size
        }
        return result
    }

    static func isLimited(_ text: String, limit: Int = maxTextBytes) -> Bool {
        text.utf8.count >= limit
    }

    static var label: String { "1 МБ" }
}

struct LimitedTextEditor: View {
    @Binding var text: String
    var limit: Int = InputLimit.maxTextBytes

    var body: some View {
        TextEditor(text: Binding(
            get: { text },
            set: { text = InputLimit.truncated($0, limit: limit) }
        ))
    }
}

struct LimitedTextField: View {
    @Binding var text: String
    var placeholder: String = ""
    var limit: Int = InputLimit.maxTextBytes

    var body: some View {
        TextField(placeholder, text: Binding(
            get: { text },
            set: { text = InputLimit.truncated($0, limit: limit) }
        ))
    }
}

struct InputSizeHint: View {
    let text: String
    var limit: Int = InputLimit.maxTextBytes

    private var bytes: Int { text.utf8.count }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: InputLimit.isLimited(text, limit: limit) ? "exclamationmark.triangle.fill" : "info.circle")
            Text("\(bytes / 1024) / \(limit / 1024) КБ · лимит \(InputLimit.label)")
        }
        .font(.caption2)
        .foregroundStyle(InputLimit.isLimited(text, limit: limit) ? .orange : .secondary)
    }
}
