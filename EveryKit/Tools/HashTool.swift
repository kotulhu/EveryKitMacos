import SwiftUI
import Foundation
import CryptoKit

enum HashAlgorithm: String, CaseIterable, Identifiable {
    case sha256 = "SHA-256"
    case sha512 = "SHA-512"
    case md5 = "MD5"
    case sha1 = "SHA-1"

    var id: String { rawValue }
}

struct HashToolView: View {
    @State private var input = "Hello, EveryKit!"
    @State private var algorithm: HashAlgorithm = .sha256
    @State private var output = ""
    @AppStorage("everykit.hash.algorithm") private var savedAlgorithm = HashAlgorithm.sha256.rawValue

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Hash Generator").font(.title2).bold()

                Picker("Algorithm", selection: $algorithm) {
                    ForEach(HashAlgorithm.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .onChange(of: algorithm) { newValue in
                    savedAlgorithm = newValue.rawValue
                    compute()
                }
                .onAppear {
                    if let restored = HashAlgorithm(rawValue: savedAlgorithm) { algorithm = restored }
                    compute()
                }

                Text("Input").font(.caption).foregroundStyle(.secondary)
                LimitedTextEditor(text: $input)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 100)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(.quaternary))
                InputSizeHint(text: input)
                HStack {
                    Button("Compute") { compute() }
                    Spacer()
                    CopyButton(text: output)
                }

                Text("Hex output").font(.caption).foregroundStyle(.secondary)
                TextEditor(text: .constant(output))
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 80)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(.quaternary))
            }
            .padding()
        }
    }

    private func compute() {
        let data = Data(input.utf8)
        let bytes: [UInt8]
        switch algorithm {
        case .sha256: bytes = Array(SHA256.hash(data: data))
        case .sha512: bytes = Array(SHA512.hash(data: data))
        case .md5: bytes = Array(Insecure.MD5.hash(data: data))
        case .sha1: bytes = Array(Insecure.SHA1.hash(data: data))
        }
        output = bytes.map { String(format: "%02x", $0) }.joined()
    }
}
