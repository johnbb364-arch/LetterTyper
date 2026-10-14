import Foundation

final class FakeDocument: TypingDocument {
    var text = ""
    var identifier = UUID()
    var selection: String?
    var readable = true
    var events: [String] = []
    var state: DocumentState {
        DocumentState(identifier: identifier, before: readable ? text : nil,
                      after: "", selection: selection)
    }
    func insert(_ text: String) { self.text += text; events.append("insert:\(text)") }
    func deleteBackward() { if !text.isEmpty { text.removeLast() }; events.append("delete") }
}

@main
 enum TypingSessionTests {
    static func main() {
        let doc = FakeDocument()
        let text = "Hi 👨‍👩‍👧‍👦 e\u{301}!\n"
        let normal = TypingSession(text: text, document: doc, typoChance: 0)
        for _ in Array(text) { _ = normal.step() }
        precondition(doc.text == text && normal.completed == text.count && !normal.active)
        precondition(doc.events.count == text.count, "One grapheme per insertion")

        let errorDoc = FakeDocument()
        let errors = TypingSession(text: "ab", document: errorDoc, typoChance: 1, random: { 0 })
        _ = errors.step()
        precondition(errorDoc.text == "b" && errors.hasPendingTypo)
        _ = errors.step()
        precondition(errorDoc.text == "a" && errors.completed == 1)
        _ = errors.step()
        _ = errors.step()
        precondition(errorDoc.text == "ab" && !errors.active)

        let stopDoc = FakeDocument()
        let stopped = TypingSession(text: "a", document: stopDoc, typoChance: 1)
        _ = stopped.step()
        precondition(!stopped.stop(repairPending: true) && stopDoc.text == "a")
        _ = stopped.step()
        precondition(stopDoc.text == "a", "No typing after Stop")

        let movedDoc = FakeDocument()
        let moved = TypingSession(text: "a", document: movedDoc, typoChance: 1)
        _ = moved.step()
        movedDoc.text = "Other field"
        movedDoc.identifier = UUID()
        precondition(moved.stop(repairPending: true))
        precondition(movedDoc.text == "Other field", "Never delete in a different field")

        let cursorDoc = FakeDocument()
        let cursor = TypingSession(text: "a", document: cursorDoc, typoChance: 1)
        _ = cursor.step()
        cursorDoc.text = "changed"
        if case .interrupted = cursor.step() {} else { preconditionFailure("Must stop on context changes") }
        precondition(cursorDoc.text == "changed")

        let noContextDoc = FakeDocument()
        noContextDoc.readable = false
        let noContext = TypingSession(text: "a", document: noContextDoc, typoChance: 1)
        _ = noContext.step()
        precondition(noContextDoc.text == "a", "Skip typos when no readable context is available")

        let dismissedDoc = FakeDocument()
        let dismissed = TypingSession(text: "a", document: dismissedDoc, typoChance: 1)
        _ = dismissed.step()
        precondition(dismissed.stop(repairPending: false) && dismissedDoc.text == "b")

        let selectedDoc = FakeDocument()
        selectedDoc.selection = "Selected"
        let selected = TypingSession(text: "a", document: selectedDoc, typoChance: 0)
        _ = selected.step()
        precondition(selectedDoc.text.isEmpty && !selected.active)
        print("PASS: Unicode, pacing, typo correction, Stop, changed fields/context, missing context, dismissal, selection")
    }
}
