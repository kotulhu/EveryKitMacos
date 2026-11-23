import SwiftUI
import Foundation

struct UUIDToolView: View {
    @State private var value = UUID().uuidString

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("UUID Generator").font(.title2).bold()
                Text("Новый UUID версии 4 (случайный).").font(.caption).foregroundStyle(.secondary)

                HStack {
                    Button("Generate") { value = UUID().uuidString }
                    Spacer()
                    CopyButton(text: value)
                }

                TextEditor(text: .constant(value))
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 60)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(.quaternary))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
}
