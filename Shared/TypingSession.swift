import Foundation

struct DocumentState: Equatable {
    let identifier: UUID
    let before: String?
    let after: String?
    let selection: String?
}

protocol TypingDocument: AnyObject {
    var state: DocumentState { get }
    func insert(_ text: String)
    func deleteBackward()
}

// UI owns timing. This object only handles one character/correction per tick.
final class TypingSession {
    enum Outcome { case advanced, finished, interrupted }
    private let document: TypingDocument
    private let characters: [Character]
    private let typoChance: Double
    private let random: () -> Double
    private var expected: DocumentState
    private var pending: Character?
    private(set) var completed = 0
    private(set) var active = true
    var total: Int { characters.count }
    var hasPendingTypo: Bool { pending != nil }

    init(text: String, document: TypingDocument, typoChance: Double,
         random: @escaping () -> Double = { Double.random(in: 0..<1) }) {
        self.document = document
        self.characters = Array(text)
        self.typoChance = min(max(typoChance, 0), 1)
        self.random = random
        self.expected = document.state
    }

    func step() -> Outcome {
        guard active else { return .finished }
        // Avoid typing into a new field or deleting after a cursor/context change.
        guard document.state == expected, document.state.selection?.isEmpty != false else {
            active = false
            return .interrupted
        }
        if let correct = pending {
            document.deleteBackward()
            document.insert(String(correct))
            pending = nil
            completed += 1
        } else if completed < characters.count {
            let correct = characters[completed]
            let alphabet = Array("abcdefghijklmnopqrstuvwxyz")
            // Restrict simulated errors to plain ASCII letters, with readable context.
            if let i = alphabet.firstIndex(of: correct),
               document.state.before != nil, random() < typoChance {
                let wrong = alphabet[(i + 1) % alphabet.count]
                document.insert(String(wrong))
                let afterInsert = document.state
                if afterInsert.before?.last == wrong {
                    pending = correct
                } else {
                    // Host transformed/rejected the error; don't delete unknown text.
                    active = false
                    return .interrupted
                }
            } else {
                document.insert(String(correct))
                completed += 1
            }
        }
        expected = document.state
        if completed == characters.count && pending == nil {
            active = false
            return .finished
        }
        return .advanced
    }

    // Only a deliberate Stop while the same field is still focused repairs a typo.
    // On dismissal/external changes, leave text alone and report an unfinished typo.
    @discardableResult
    func stop(repairPending: Bool) -> Bool {
        if repairPending, active, let correct = pending, document.state == expected {
            document.deleteBackward()
            document.insert(String(correct))
            pending = nil
            completed += 1
        }
        active = false
        return pending != nil
    }
}
