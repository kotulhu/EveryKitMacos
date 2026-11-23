import SwiftUI
import AppKit

enum Tool: String, CaseIterable, Identifiable {
    case json = "JSON Formatter"
    case base64 = "Base64"
    case url = "URL Encode"
    case hash = "Hash Generator"
    case uuid = "UUID Generator"
    case image = "Image Converter"
    case timestamp = "Timestamp"
    case password = "Password Generator"
    case fishText = "FishText"
    case cron = "Cron Parser"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .json: return "curlybraces"
        case .base64: return "b64"
        case .url: return "link"
        case .hash: return "number"
        case .uuid: return "uuid"
        case .image: return "photo"
        case .timestamp: return "clock"
        case .password: return "key"
        case .fishText: return "text.bubble"
        case .cron: return "calendar.badge.clock"
        }
    }

    @ViewBuilder
    var destination: some View {
        switch self {
        case .json: JSONToolView()
        case .base64: Base64ToolView()
        case .url: URLToolView()
        case .hash: HashToolView()
        case .uuid: UUIDToolView()
        case .image: ImageToolView()
        case .timestamp: TimestampToolView()
        case .password: PasswordToolView()
        case .fishText: FishTextToolView()
        case .cron: CronToolView()
        }
    }
}

struct ContentView: View {
    @State private var selection: Tool = .json

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Section("Tools") {
                    ForEach(Tool.allCases) { tool in
                        Label(tool.rawValue, systemImage: tool.symbol)
                            .tag(tool)
                    }
                }
                Section {
                    Button {
                        NSApp.terminate(nil)
                    } label: {
                        Label("Quit EveryKit", systemImage: "power")
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut("q", modifiers: .command)
                }
            }
            .listStyle(.sidebar)
            .frame(width: 200)
        } detail: {
            selection.destination
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationSplitViewStyle(.balanced)
        .frame(width: 660, height: 560)
    }
}
