import SwiftUI
import Foundation

struct TimestampToolView: View {
    @State private var timestampInput = "1700000000"
    @State private var unit: TimestampUnit = .seconds
    @State private var date = Date()
    @State private var isoString = ""
    @State private var localString = ""
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Timestamp Converter").font(.title2).bold()

                GroupBox("Unix → Дата") {
                    Picker("Единица", selection: $unit) {
                        ForEach(TimestampUnit.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)

                    HStack {
                        LimitedTextField(text: $timestampInput, placeholder: "Timestamp")
                            .textFieldStyle(.roundedBorder)
                        Button("Convert") { convertToDate() }
                    }

                    if let errorMessage {
                        Text(errorMessage).font(.caption).foregroundStyle(.red)
                    }

                    labeledOutput(title: "ISO 8601", value: isoString)
                    labeledOutput(title: "Локальное время", value: localString)
                }

                GroupBox("Дата → Unix") {
                    DatePicker("Дата и время", selection: $date)
                        .datePickerStyle(.compact)
                    labeledOutput(title: "Секунды", value: "\(Int(date.timeIntervalSince1970))")
                    labeledOutput(title: "Миллисекунды", value: "\(Int(date.timeIntervalSince1970 * 1000))")
                }
            }
            .padding()
        }
        .onAppear { convertToDate() }
    }

    private func labeledOutput(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title).font(.caption).foregroundStyle(.secondary)
                Spacer()
                CopyButton(text: value, label: "Copy")
            }
            Text(value)
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 6))
        }
    }

    private func convertToDate() {
        guard let raw = Double(timestampInput.trimmingCharacters(in: .whitespaces)) else {
            errorMessage = "Введите корректное число."
            isoString = ""
            localString = ""
            return
        }
        let seconds = unit == .seconds ? raw : raw / 1000
        let converted = Date(timeIntervalSince1970: seconds)
        date = converted

        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime]
        isoString = iso.string(from: converted)

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .full
        localString = formatter.string(from: converted)
        errorMessage = nil
    }
}

enum TimestampUnit: String, CaseIterable, Identifiable {
    case seconds = "Секунды"
    case milliseconds = "Миллисекунды"
    var id: String { rawValue }
}
