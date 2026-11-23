import SwiftUI
import Foundation

struct CronToolView: View {
    @AppStorage("everykit.cron.expression") private var expression = "0 12 * * 2"
    @State private var explanation = ""

    private let weekdayNames: [Int: String] = [
        0: "воскресенье", 1: "понедельник", 2: "вторник", 3: "среда",
        4: "четверг", 5: "пятница", 6: "суббота"
    ]
    private let monthNames: [Int: String] = [
        1: "января", 2: "февраля", 3: "марта", 4: "апреля", 5: "мая", 6: "июня",
        7: "июля", 8: "августа", 9: "сентября", 10: "октября", 11: "ноября", 12: "декабря"
    ]
    private let weekdayAliases: [String: Int] = [
        "sun": 0, "mon": 1, "tue": 2, "wed": 3, "thu": 4, "fri": 5, "sat": 6,
        "вс": 0, "пн": 1, "вт": 2, "ср": 3, "чт": 4, "пт": 5, "сб": 6
    ]
    private let monthAliases: [String: Int] = [
        "jan": 1, "feb": 2, "mar": 3, "apr": 4, "may": 5, "jun": 6,
        "jul": 7, "aug": 8, "sep": 9, "oct": 10, "nov": 11, "dec": 12,
        "янв": 1, "фев": 2, "мар": 3, "апр": 4, "май": 5, "июн": 6,
        "июл": 7, "авг": 8, "сен": 9, "окт": 10, "ноя": 11, "дек": 12
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Cron Parser").font(.title2).bold()
                Text("5 полей: минута час день месяц день_недели").font(.caption).foregroundStyle(.secondary)

                HStack {
                    LimitedTextField(text: $expression, placeholder: "0 12 * * 2")
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                    Button("Parse") { explain() }
                }
                .onAppear { explain() }

                TextEditor(text: .constant(explanation))
                    .font(.system(.body))
                    .frame(height: 100)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(.quaternary))

                HStack {
                    Spacer()
                    CopyButton(text: explanation)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }

    private func explain() {
        let fields = expression.split(whereSeparator: { $0 == " " || $0 == "\t" }).map(String.init)
        guard fields.count == 5 else {
            explanation = "Ожидается 5 полей, получено \(fields.count)."
            return
        }

        guard let minute = parse(fields[0], min: 0, max: 59, aliases: [:]),
              let hour = parse(fields[1], min: 0, max: 23, aliases: [:]),
              let day = parse(fields[2], min: 1, max: 31, aliases: [:]),
              let month = parse(fields[3], min: 1, max: 12, aliases: monthAliases),
              let weekday = parse(fields[4], min: 0, max: 6, aliases: weekdayAliases) else {
            explanation = "Не удалось разобрать выражение. Проверьте значения и шаги."
            return
        }

        let allMinutes = Set(0...59)
        let allHours = Set(0...23)
        let allDays = Set(1...31)
        let allMonths = Set(1...12)
        let allWeekdays = Set(0...6)
        let anyDay = day == allDays && weekday == allWeekdays

        if minute == allMinutes && hour == allHours && month == allMonths && anyDay {
            explanation = "Каждую минуту"
            return
        }

        if let step = stepValue(fields[0]), minute != allMinutes,
           hour == allHours, month == allMonths, anyDay, step > 1 {
            explanation = "Каждые \(step) \(russianMinutes(step))"
            return
        }

        if minute.count == 1, hour.count == 1, month == allMonths {
            let time = String(format: "%02d:%02d", hour.first!, minute.first!)
            if weekday != allWeekdays && day == allDays {
                let names = weekday.sorted().compactMap { weekdayNames[$0] }
                explanation = "\(dayWord(names.count)) \(names.joined(separator: ", ")) в \(time)"
                return
            }
            if day != allDays && weekday == allWeekdays {
                explanation = "\(dayNumbers(day)) числа каждого месяца в \(time)"
                return
            }
            if anyDay {
                explanation = "Каждый день в \(time)"
                return
            }
        }

        var parts: [String] = []
        parts.append(minuteClause(fields[0], values: minute))
        parts.append(hourClause(fields[1], values: hour))
        if day != allDays { parts.append("числа \(dayNumbers(day))") }
        if month != allMonths {
            parts.append("в \(month.sorted().compactMap { monthNames[$0] }.joined(separator: ", "))")
        }
        if weekday != allWeekdays {
            parts.append("по \(weekday.sorted().compactMap { weekdayNames[$0] }.joined(separator: ", "))")
        }
        explanation = parts.joined(separator: ", ").capitalizedFirst
    }

    private func parse(_ raw: String, min: Int, max: Int, aliases: [String: Int]) -> Set<Int>? {
        var result: Set<Int> = []
        for component in raw.split(separator: ",") {
            var text = String(component)
            var step = 1
            if let slash = text.firstIndex(of: "/") {
                step = Int(text[text.index(after: slash)...]) ?? 1
                text = String(text[..<slash])
            }
            guard step > 0 else { return nil }

            var start = min
            var end = max
            if text == "*" {
                // весь диапазон
            } else if let dash = text.firstIndex(of: "-") {
                guard let left = number(text[..<dash], aliases: aliases),
                      let right = number(text[text.index(after: dash)...], aliases: aliases) else { return nil }
                start = left
                end = right
            } else if let value = number(Substring(text), aliases: aliases) {
                start = value
                end = value
            } else {
                return nil
            }
            guard start >= min, end <= max, start <= end else { return nil }
            var value = start
            while value <= end {
                result.insert(value)
                value += step
            }
        }
        return result.isEmpty ? nil : result
    }

    private func number(_ text: Substring, aliases: [String: Int]) -> Int? {
        if let value = Int(text) { return value }
        return aliases[String(text).lowercased()]
    }

    private func stepValue(_ raw: String) -> Int? {
        guard let slash = raw.firstIndex(of: "/") else { return nil }
        return Int(raw[raw.index(after: slash)...])
    }

    private func minuteClause(_ raw: String, values: Set<Int>) -> String {
        if values == Set(0...59) { return "каждую минуту" }
        if raw.hasPrefix("*"), let step = stepValue(raw) { return "каждые \(step) \(russianMinutes(step))" }
        if values.count == 1 { return "в минуту \(values.first!)" }
        return "в минуты \(values.sorted().map(String.init).joined(separator: ", "))"
    }

    private func hourClause(_ raw: String, values: Set<Int>) -> String {
        if values == Set(0...23) { return "каждый час" }
        if raw.hasPrefix("*"), let step = stepValue(raw) { return "каждые \(step) \(russianHours(step))" }
        if values.count == 1 { return "в \(values.first!) часу" }
        return "в часы \(values.sorted().map(String.init).joined(separator: ", "))"
    }

    private func russianMinutes(_ value: Int) -> String {
        let mod10 = value % 10, mod100 = value % 100
        if mod10 == 1 && mod100 != 11 { return "минуту" }
        if mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) { return "минуты" }
        return "минут"
    }

    private func russianHours(_ value: Int) -> String {
        let mod10 = value % 10, mod100 = value % 100
        if mod10 == 1 && mod100 != 11 { return "час" }
        if mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) { return "часа" }
        return "часов"
    }

    private func dayWord(_ count: Int) -> String { count == 1 ? "Каждый" : "Каждые" }

    private func dayNumbers(_ values: Set<Int>) -> String {
        values.sorted().map(String.init).joined(separator: ", ")
    }
}

private extension String {
    var capitalizedFirst: String { prefix(1).uppercased() + dropFirst() }
}
