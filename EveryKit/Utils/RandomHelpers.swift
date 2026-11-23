import Foundation

enum RandomHelpers {
    private static let uppercase = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    private static let lowercase = Array("abcdefghijklmnopqrstuvwxyz")
    private static let digits = Array("0123456789")
    private static let symbols = Array("!@#$%^&*()-_=+[]{};:,.?/")

    static func randomString(length: Int, alphabet: [Character]) -> String {
        guard !alphabet.isEmpty, length > 0 else { return "" }
        var generator = SystemRandomNumberGenerator()
        return String((0..<length).map { _ in
            alphabet[Int.random(in: 0..<alphabet.count, using: &generator)]
        })
    }

    static func password(
        length: Int,
        uppercase includeUppercase: Bool,
        lowercase includeLowercase: Bool,
        digits includeDigits: Bool,
        symbols includeSymbols: Bool
    ) -> (value: String, alphabetSize: Int) {
        var groups: [[Character]] = []
        if includeUppercase { groups.append(uppercase) }
        if includeLowercase { groups.append(lowercase) }
        if includeDigits { groups.append(digits) }
        if includeSymbols { groups.append(symbols) }

        let alphabet = groups.flatMap { $0 }
        guard !alphabet.isEmpty else { return ("", 0) }

        var generator = SystemRandomNumberGenerator()
        var characters: [Character] = []
        if length >= groups.count {
            for group in groups {
                characters.append(group[Int.random(in: 0..<group.count, using: &generator)])
            }
        }
        characters.append(contentsOf: randomString(length: max(0, length - characters.count), alphabet: alphabet))
        characters.shuffle(using: &generator)
        return (String(characters), alphabet.count)
    }
}
