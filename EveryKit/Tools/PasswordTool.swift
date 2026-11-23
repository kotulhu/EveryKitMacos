import SwiftUI
import Foundation

struct PasswordToolView: View {
    @AppStorage("everykit.password.length") private var length = 20
    @AppStorage("everykit.password.uppercase") private var uppercase = true
    @AppStorage("everykit.password.lowercase") private var lowercase = true
    @AppStorage("everykit.password.digits") private var digits = true
    @AppStorage("everykit.password.symbols") private var symbols = true

    @State private var password = ""
    @State private var entropy: Double = 0

    private var alphabetSize: Int {
        (uppercase ? 26 : 0) + (lowercase ? 26 : 0) + (digits ? 10 : 0) + (symbols ? 23 : 0)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Password Generator").font(.title2).bold()

                HStack {
                    Text("Длина: \(length)")
                    Slider(value: Binding(
                        get: { Double(length) },
                        set: { length = Int($0.rounded()) }
                    ), in: 8...64, step: 1)
                }

                Toggle("Заглавные (A–Z)", isOn: $uppercase)
                Toggle("Строчные (a–z)", isOn: $lowercase)
                Toggle("Цифры (0–9)", isOn: $digits)
                Toggle("Спецсимволы (!@#…)", isOn: $symbols)

                HStack {
                    Button("Generate") { generate() }
                    Spacer()
                    CopyButton(text: password)
                }
                .onAppear { generate() }
                .onChange(of: length) { _ in generate() }
                .onChange(of: uppercase) { _ in generate() }
                .onChange(of: lowercase) { _ in generate() }
                .onChange(of: digits) { _ in generate() }
                .onChange(of: symbols) { _ in generate() }

                TextEditor(text: .constant(password))
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 70)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(.quaternary))

                Text(String(format: "Энтропия: %.1f бит", entropy))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }

    private func generate() {
        let result = RandomHelpers.password(
            length: length,
            uppercase: uppercase,
            lowercase: lowercase,
            digits: digits,
            symbols: symbols
        )
        password = result.value
        let size = result.alphabetSize
        entropy = size > 0 ? Double(length) * (log(Double(size)) / log(2)) : 0
    }
}
