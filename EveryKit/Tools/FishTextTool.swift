import SwiftUI
import Foundation

enum FishTextMode: String, CaseIterable, Identifiable {
    case paragraphs = "Абзацы"
    case sentences = "Предложения"
    case words = "Слова"
    var id: String { rawValue }
}

private let fishWords: [String] = """
дом окно дверь стол стул книга ручка бумага компьютер телефон часы зеркало лампа шкаф диван кровать подушка одеяло пол стена крыша квартира улица дорога мост парк сад дерево трава цветы листья ветка
солнце луна звезда небо облако ветер дождь снег туман гроза радуга погода тепло холод жара мороз осень зима весна лето утро день вечер ночь время минута секунда час неделя месяц год
человек друг семья мама папа брат сестра сын дочь бабушка сосед коллега учитель врач инженер программист художник музыкант писатель повар водитель мастер студент школьник
работа учёба задача проект план идея результат ответ вопрос пример правило метод способ опыт навык знание наука история математика физика биология литература музыка живопись кино театр спорт игра прогулка поездка отдых сон
еда хлеб вода чай кофе молоко суп каша салат фрукты овощи мясо рыба сыр масло сахар соль город село река озеро море гора лес поле берег остров завод магазин больница школа библиотека музей стадион
счастье радость грусть удивление интерес любовь дружба доверие надежда мечта цель смелость тишина шум запах цвет вкус свет тень тепло простор порядок покой движение
""".split(separator: " ").map(String.init)

struct FishTextToolView: View {
    @AppStorage("everykit.fish.mode") private var savedMode = FishTextMode.paragraphs.rawValue
    @AppStorage("everykit.fish.count") private var count = 3
    @State private var mode: FishTextMode = .paragraphs
    @State private var text = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("FishText — рыбный текст").font(.title2).bold()

                Picker("Режим", selection: $mode) {
                    ForEach(FishTextMode.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .onChange(of: mode) { newValue in
                    savedMode = newValue.rawValue
                    generate()
                }
                .onAppear {
                    if let restored = FishTextMode(rawValue: savedMode) { mode = restored }
                    generate()
                }

                Stepper("Количество: \(count)", value: $count, in: 1...50)
                    .onChange(of: count) { _ in generate() }

                HStack {
                    Button("Generate") { generate() }
                    Spacer()
                    CopyButton(text: text)
                }

                TextEditor(text: .constant(text))
                    .font(.system(.body))
                    .frame(minHeight: 180)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(.quaternary))
            }
            .padding()
        }
    }

    private func generate() {
        var generator = SystemRandomNumberGenerator()
        switch mode {
        case .words:
            text = (0..<count).map { _ in randomWord(using: &generator) }.joined(separator: " ")
        case .sentences:
            text = (0..<count).map { _ in sentence(using: &generator) }.joined(separator: " ")
        case .paragraphs:
            text = (0..<count).map { _ in
                (0..<Int.random(in: 3...6, using: &generator))
                    .map { _ in sentence(using: &generator) }
                    .joined(separator: " ")
            }.joined(separator: "\n\n")
        }
    }

    private func randomWord(using generator: inout SystemRandomNumberGenerator) -> String {
        fishWords[Int.random(in: 0..<fishWords.count, using: &generator)]
    }

    private func sentence(using generator: inout SystemRandomNumberGenerator) -> String {
        let length = Int.random(in: 5...12, using: &generator)
        var selected: [String] = []
        while selected.count < length {
            let word = randomWord(using: &generator)
            if selected.last != word { selected.append(word) }
        }
        let body = selected.joined(separator: " ")
        return body.prefix(1).uppercased() + body.dropFirst() + "."
    }
}
