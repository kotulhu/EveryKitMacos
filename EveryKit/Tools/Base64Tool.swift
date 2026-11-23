import SwiftUI
import Foundation

struct Base64ToolView: View {
    @State private var input = "Hello, EveryKit!"
    @State private var output = ""
    @State private var urlSafe = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Base64 Encode / Decode").font(.title2).bold()

                Toggle("URL-safe Base64", isOn: $urlSafe)

                Text("Input").font(.caption).foregroundStyle(.secondary)
                LimitedTextEditor(text: $input)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 110)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(.quaternary))
                InputSizeHint(text: input)

                HStack {
                    Button("Encode") { encode() }
                    Button("Decode") { decode() }
                    Spacer()
                    CopyButton(text: output)
                }

                if let errorMessage {
                    Text(errorMessage).font(.caption).foregroundStyle(.red)
                }

                Text("Output").font(.caption).foregroundStyle(.secondary)
                TextEditor(text: .constant(output))
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 110)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(.quaternary))
            }
            .padding()
        }
    }

    private func encode() {
        let base = Data(input.utf8).base64EncodedString()
        output = urlSafe
            ? base.replacingOccurrences(of: "+", with: "-")
                   .replacingOccurrences(of: "/", with: "_")
                   .replacingOccurrences(of: "=", with: "")
            : base
        errorMessage = nil
    }

    private func decode() {
        var value = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if urlSafe {
            value = value.replacingOccurrences(of: "-", with: "+")
                         .replacingOccurrences(of: "_", with: "/")
        }
        value = value.replacingOccurrences(of: " ", with: "")
        let remainder = value.count % 4
        if remainder != 0 {
            value += String(repeating: "=", count: 4 - remainder)
        }
        guard let data = Data(base64Encoded: value, options: .ignoreUnknownCharacters) else {
            output = ""
            errorMessage = "Не удалось декодировать Base64."
            return
        }
        output = String(decoding: data, as: UTF8.self)
        errorMessage = nil
    }
}
