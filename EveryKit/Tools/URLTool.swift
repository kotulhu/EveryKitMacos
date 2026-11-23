import SwiftUI
import Foundation

struct URLToolView: View {
    @State private var input = "example.com/search?q=Swift UI&lang=ru"
    @State private var output = ""
    @State private var encodeQueryOnly = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("URL Encode / Decode").font(.title2).bold()

                Toggle("Кодировать как отдельный компонент", isOn: $encodeQueryOnly)

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

                Text("Output").font(.caption).foregroundStyle(.secondary)
                TextEditor(text: .constant(output))
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 110)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(.quaternary))
            }
            .padding()
        }
    }

    private var allowedCharacters: CharacterSet {
        let quote = CharacterSet(charactersIn: "\"")
        return encodeQueryOnly
            ? .alphanumerics.union(CharacterSet(charactersIn: "-._~")).union(quote)
            : .urlQueryAllowed.union(quote)
    }

    private func encode() {
        output = input.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? ""
    }

    private func decode() {
        output = input.removingPercentEncoding ?? input
    }
}
