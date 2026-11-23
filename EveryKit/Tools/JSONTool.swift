import SwiftUI
import Foundation

private indirect enum JSONValue: Codable {
    case object([String: JSONValue])
    case array([JSONValue])
    case string(String)
    case integer(Int)
    case number(Double)
    case bool(Bool)
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Int.self) {
            self = .integer(value)
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([JSONValue].self) {
            self = .array(value)
        } else if let value = try? container.decode([String: JSONValue].self) {
            self = .object(value)
        } else {
            throw DecodingError.typeMismatch(
                JSONValue.self,
                .init(codingPath: decoder.codingPath, debugDescription: "Unsupported JSON value")
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .object(let value): try container.encode(value)
        case .array(let value): try container.encode(value)
        case .string(let value): try container.encode(value)
        case .integer(let value): try container.encode(value)
        case .number(let value): try container.encode(value)
        case .bool(let value): try container.encode(value)
        case .null: try container.encodeNil()
        }
    }
}

struct JSONToolView: View {
    @State private var input = "{\"name\":\"EveryKit\",\"items\":[1,2,3],\"active\":true}"
    @State private var output = ""
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("JSON Formatter").font(.title2).bold()
                LimitedTextEditor(text: $input)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 140)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(.quaternary))
                InputSizeHint(text: input)

                HStack {
                    Button("Format") { format(pretty: true) }
                    Button("Minify") { format(pretty: false) }
                    Spacer()
                    CopyButton(text: output)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .textSelection(.enabled)
                }

                TextEditor(text: .constant(output))
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 140)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(.quaternary))
            }
            .padding()
        }
    }

    private func format(pretty: Bool) {
        let data = Data(input.utf8)
        do {
            let decoder = JSONDecoder()
            let value = try decoder.decode(JSONValue.self, from: data)
            let encoder = JSONEncoder()
            encoder.outputFormatting = pretty ? [.prettyPrinted, .sortedKeys] : [.sortedKeys]
            let result = try encoder.encode(value)
            output = String(decoding: result, as: UTF8.self)
            errorMessage = nil
        } catch {
            output = ""
            errorMessage = parseErrorDescription(for: data, fallback: error.localizedDescription)
        }
    }

    private func parseErrorDescription(for data: Data, fallback: String) -> String {
        do {
            _ = try JSONSerialization.jsonObject(with: data, options: [])
            return "Ошибка форматирования: \(fallback)"
        } catch let error as NSError {
            let details = error.userInfo["NSDebugDescription"] as? String ?? fallback
            if let position = extractNumber(in: details, after: "character ") {
                let location = min(position, input.count)
                let prefix = input.prefix(location)
                let lines = prefix.components(separatedBy: "\n")
                return "Ошибка парсинга: строка \(lines.count), столбец \((lines.last?.count ?? 0) + 1). \(details)"
            }
            if let line = extractNumber(in: details, after: "line "),
               let column = extractNumber(in: details, after: "column ") {
                return "Ошибка парсинга: строка \(line), столбец \(column)."
            }
            return "Ошибка парсинга: \(details)"
        }
    }

    private func extractNumber(in text: String, after marker: String) -> Int? {
        guard let range = text.range(of: marker) else { return nil }
        let tail = text[range.upperBound...]
        let digits = tail.prefix(while: { $0.isNumber })
        return Int(digits)
    }
}

struct CopyButton: View {
    let text: String
    var label: String = "Copy"

    var body: some View {
        Button {
            Clipboard.copy(text)
        } label: {
            Label(label, systemImage: "doc.on.doc")
        }
        .disabled(text.isEmpty)
    }
}
