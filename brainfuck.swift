import Foundation

enum MatchDirection { case forward, backward }
enum MatchType { case opener, closer }

extension String {
    func stringAt(_ index: Int) -> String? {
        guard !self.isEmpty else { return nil }
        return String(self[self.index(self.startIndex, offsetBy: index)])
    }

    func nextMatchingClosingBracket(index: Int) -> Int? {
        return matchingBracket(index: index)
    }

    func previousMatchingOpeningBracket(index: Int) -> Int? {
        return matchingBracket(index: index, direction: .backward, matchType: .opener)
    }

    private func matchingBracket(index: Int, direction: MatchDirection = .forward, matchType: MatchType = .closer) -> Int? {
        var index = index + (direction == .forward ? 1 : -1)
        var count = 1
        while index < self.count && index >= 0 {
            if stringAt(index) == "[" { count += (matchType == .opener ? -1 : 1) }
            if stringAt(index) == "]" { count += (matchType == .opener ? 1 : -1) }
            if count == 0 { return index }
            index += (direction == .forward ? 1 : -1)
        }; return nil
    }
}

class BFF {
    private var source: String
    private var byteArray: [Int8]
    private let byteCount = 30_000

    init(source: String) {
        self.source = source
        self.byteArray = Array<Int8>.init(repeating: 0, count: byteCount)
    }

    func run() {
        var pointer = 0
        var sourceIndex = 0
        while sourceIndex >= 0 && sourceIndex < source.count {
            let instruction = source.stringAt(sourceIndex)!
            switch instruction {
            case ">": pointer += 1; sourceIndex += 1
            case "<": pointer -= 1; sourceIndex += 1
            case "+": byteArray[pointer] += 1; sourceIndex += 1
            case "-": byteArray[pointer] -= 1; sourceIndex += 1
            case ".":
                let string = String(Character(Unicode.Scalar(UInt8(byteArray[pointer]))))
                print(string, terminator: "")
                sourceIndex += 1
            case ",": byteArray[pointer] = Int8(getchar()); sourceIndex += 1
            case "[":
                guard let matchingIndex = source.nextMatchingClosingBracket(index: sourceIndex) else {
                    fatalError("Unbalanced opening brace at index: \(sourceIndex)")
                }
                sourceIndex = byteArray[pointer] == 0 ? matchingIndex + 1 : sourceIndex + 1
            case "]":
                guard let matchingIndex = source.previousMatchingOpeningBracket(index: sourceIndex) else {
                    fatalError("Unbalanced closing brace at index: \(sourceIndex)")
                }
                sourceIndex = byteArray[pointer] != 0 ? matchingIndex : sourceIndex + 1
            // all other chars are valid, but considered comments
            default: sourceIndex += 1
            }
        }
    }
}

let input = ">++++++++[-<+++++++++>]<.>>+>-[+]++>++>+++[>[->+++<<+++>]<<]>-----.>->+++..+++.>-.<<+[>[+>+]>>]<--------------.>>.+++.------.--------.>+.>+."
let driver = BFF(source: input)
driver.run()
