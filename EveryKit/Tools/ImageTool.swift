import SwiftUI
import AppKit
import UniformTypeIdentifiers

enum ImageFormat: String, CaseIterable, Identifiable {
    case png
    case jpeg
    case tiff
    case bmp

    var id: String { rawValue }

    var title: String {
        switch self {
        case .png: return "PNG"
        case .jpeg: return "JPEG"
        case .tiff: return "TIFF"
        case .bmp: return "BMP"
        }
    }

    var fileExtension: String { rawValue }

    var contentType: UTType {
        UTType(filenameExtension: fileExtension) ?? .image
    }

    var representation: NSBitmapImageRep.FileType {
        switch self {
        case .png: return .png
        case .jpeg: return .jpeg
        case .tiff: return .tiff
        case .bmp: return .bmp
        }
    }
}

struct ImageToolView: View {
    @State private var image: NSImage?
    @State private var sourceName = "Нет файла"
    @State private var sourceBytes = 0
    @State private var format: ImageFormat = .png
    @State private var quality = 0.9
    @State private var converted: Data?
    @State private var status = "Откройте изображение или вставьте его из буфера обмена."

    private let maxPixels: Double = 100_000_000

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Image Converter").font(.title2).bold()

                HStack {
                    Button("Open Image…") { openImage() }
                    Button("Paste") { pasteImage() }
                    Spacer()
                }

                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.quaternary.opacity(0.35))
                    if let image {
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(8)
                    } else {
                        Label("Предпросмотр", systemImage: "photo")
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(height: 150)

                Text("\(sourceName) · \(sourceBytes / 1024) КБ")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Picker("Формат", selection: $format) {
                    ForEach(ImageFormat.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.segmented)
                .onChange(of: format) { _ in convert() }

                if format == .jpeg {
                    HStack {
                        Text("Качество: \(Int(quality * 100))%")
                        Slider(value: $quality, in: 0.1...1.0, step: 0.05)
                            .onChange(of: quality) { _ in convert() }
                    }
                }

                HStack {
                    Button("Save As…") { saveImage() }
                        .disabled(converted == nil)
                    Spacer()
                    if let converted {
                        Text("\(converted.count / 1024) КБ")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Text(status)
                    .font(.caption)
                    .foregroundStyle(status.hasPrefix("Ошибка") ? .red : .secondary)
                    .textSelection(.enabled)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .onAppear { convert() }
    }

    private func openImage() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.image]
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            load(from: url)
        }
    }

    private func load(from url: URL) {
        do {
            let data = try Data(contentsOf: url)
            guard data.count <= InputLimit.maxImageBytes else {
                fail("Ошибка: файл больше \(InputLimit.maxImageBytes / 1_048_576) МБ.")
                return
            }
            guard let loaded = NSImage(data: data) else {
                fail("Ошибка: не удалось прочитать изображение.")
                return
            }
            let pixels = Double(loaded.size.width) * Double(loaded.size.height)
            guard pixels <= maxPixels else {
                fail("Ошибка: слишком большое разрешение (более 100 Мп).")
                return
            }
            image = loaded
            sourceName = url.lastPathComponent
            sourceBytes = data.count
            status = "Изображение загружено."
            convert()
        } catch {
            fail("Ошибка: \(error.localizedDescription)")
        }
    }

    private func pasteImage() {
        guard let pasted = NSPasteboard.general.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage else {
            fail("Ошибка: в буфере обмена нет изображения.")
            return
        }
        let pixels = Double(pasted.size.width) * Double(pasted.size.height)
        guard pixels <= maxPixels else {
            fail("Ошибка: слишком большое разрешение (более 100 Мп).")
            return
        }
        image = pasted
        sourceName = "Из буфера обмена"
        sourceBytes = 0
        status = "Изображение вставлено."
        convert()
    }

    private func convert() {
        guard let image else {
            converted = nil
            return
        }
        guard let tiff = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff) else {
            fail("Ошибка: не удалось подготовить изображение.")
            return
        }

        let properties: [NSBitmapImageRep.PropertyKey: Any] = format == .jpeg
            ? [.compressionFactor: quality]
            : [:]

        guard let data = bitmap.representation(using: format.representation, properties: properties) else {
            fail("Ошибка: конвертация в \(format.title) не удалась.")
            return
        }
        converted = data
        status = "Готово: \(format.title), \(data.count / 1024) КБ."
    }

    private func saveImage() {
        guard let converted else { return }
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "everykit.\(format.fileExtension)"
        panel.allowedContentTypes = [format.contentType]
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            do {
                try converted.write(to: url)
                status = "Сохранено: \(url.lastPathComponent)"
            } catch {
                fail("Ошибка сохранения: \(error.localizedDescription)")
            }
        }
    }

    private func fail(_ message: String) {
        status = message
        converted = nil
    }
}
