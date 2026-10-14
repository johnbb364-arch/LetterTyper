import UIKit

private final class ProxyDocument: TypingDocument {
    weak var controller: UIInputViewController?
    private let absentIdentifier = UUID()
    init(_ controller: UIInputViewController) { self.controller = controller }
    var state: DocumentState {
        guard let proxy = controller?.textDocumentProxy else {
            return DocumentState(identifier: absentIdentifier, before: nil, after: nil, selection: nil)
        }
        return DocumentState(identifier: proxy.documentIdentifier,
                             before: proxy.documentContextBeforeInput,
                             after: proxy.documentContextAfterInput,
                             selection: proxy.selectedText)
    }
    func insert(_ text: String) { controller?.textDocumentProxy.insertText(text) }
    func deleteBackward() { controller?.textDocumentProxy.deleteBackward() }
}

final class KeyboardViewController: UIInputViewController {
    private var snippet = "Hello! This is my letter-by-letter keyboard."
    private var timer: Timer?
    private var session: TypingSession?
    private let preview = UILabel()
    private let status = UILabel()
    private let speedLabel = UILabel()
    private let speed = UISlider()
    private let typos = UISwitch()
    private let load = UIButton(type: .system)
    private let start = UIButton(type: .system)
    private let globe = UIButton(type: .system)
    private var heightConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(hostWillResignActive),
                                               name: .NSExtensionHostWillResignActive, object: nil)
        view.backgroundColor = .secondarySystemBackground
        snippet = UserDefaults.standard.string(forKey: "snippet") ?? snippet
        preview.numberOfLines = 2
        preview.font = .systemFont(ofSize: 15)
        preview.lineBreakMode = .byTruncatingTail
        preview.text = snippet
        status.numberOfLines = 2
        status.font = .systemFont(ofSize: 12)
        status.text = "Load text, then Start. Keep this field focused."
        speed.minimumValue = 0.5
        speed.maximumValue = 30
        let savedSpeed = UserDefaults.standard.float(forKey: "speed")
        speed.value = savedSpeed > 0 ? savedSpeed : 8
        speed.addTarget(self, action: #selector(speedChanged), for: .valueChanged)
        speedLabel.font = .systemFont(ofSize: 14)
        updateSpeedLabel()
        let typoLabel = UILabel()
        typoLabel.text = "Simulate typos (8%)"
        typoLabel.font = .systemFont(ofSize: 14)
        typos.isOn = UserDefaults.standard.bool(forKey: "typos")
        typos.addTarget(self, action: #selector(typosChanged), for: .valueChanged)
        let typoRow = UIStackView(arrangedSubviews: [typoLabel, typos])
        typoRow.distribution = .equalSpacing
        configure(load, "Load copied text", #selector(loadText))
        configure(start, "Start", #selector(startTyping))
        let stop = UIButton(type: .system)
        configure(stop, "Stop", #selector(stopTyping))
        stop.setTitleColor(.systemRed, for: .normal)
        globe.setTitle("🌐", for: .normal)
        globe.accessibilityLabel = "Next keyboard"
        globe.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        let buttons = UIStackView(arrangedSubviews: [globe, load, start, stop])
        buttons.spacing = 8
        buttons.distribution = .fillProportionally
        buttons.heightAnchor.constraint(equalToConstant: 44).isActive = true
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        let stack = UIStackView(arrangedSubviews: [preview, speedLabel, speed, typoRow, buttons, status])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 10),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -10),
            stack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor, constant: -12),
            stack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -24)
        ])
        heightConstraint = view.heightAnchor.constraint(equalToConstant: 290)
        heightConstraint?.priority = .defaultHigh
        heightConstraint?.isActive = true
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        globe.isHidden = !needsInputModeSwitchKey
    }

    override func viewWillDisappear(_ animated: Bool) {
        cancelForExternalChange()
        super.viewWillDisappear(animated)
    }

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        // Document/context is checked on every tick. Only a different field is
        // stopped here, because hosts may notify after our own text insertions.
        if let session, session.active, let currentDocument,
           textDocumentProxy.documentIdentifier != currentDocument {
            cancelForExternalChange()
        }
    }

    private var currentDocument: UUID?

    private func configure(_ button: UIButton, _ title: String, _ action: Selector) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.addTarget(self, action: action, for: .touchUpInside)
    }

    @objc private func speedChanged() {
        UserDefaults.standard.set(speed.value, forKey: "speed")
        updateSpeedLabel()
    }
    private func updateSpeedLabel() {
        speedLabel.text = String(format: "Speed: %.1f characters / second", speed.value)
    }
    @objc private func typosChanged() { UserDefaults.standard.set(typos.isOn, forKey: "typos") }

    @objc private func loadText() {
        guard hasFullAccess else {
            status.text = "Enable Allow Full Access in Keyboard Settings to load copied text. Demo works without it."
            return
        }
        guard let text = UIPasteboard.general.string, !text.isEmpty, text.count <= 10_000 else {
            status.text = "Copy plain text first (1–10,000 characters); allow Paste if iOS asks."
            return
        }
        snippet = text
        UserDefaults.standard.set(text, forKey: "snippet")
        preview.text = text
        status.text = "Loaded \(text.count) characters. Start inserts at the cursor."
    }

    @objc private func startTyping() {
        guard timer == nil else { return }
        guard textDocumentProxy.selectedText?.isEmpty != false else {
            status.text = "Place the cursor first; selected text would be replaced."
            return
        }
        currentDocument = textDocumentProxy.documentIdentifier
        session = TypingSession(text: snippet, document: ProxyDocument(self), typoChance: typos.isOn ? 0.08 : 0)
        setRunning(true)
        status.text = "Typing… Stop ends this run."
        let timer = Timer(timeInterval: 1 / Double(speed.value), repeats: true) { [weak self] _ in
            self?.tick()
        }
        self.timer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    private func tick() {
        guard let session else { return }
        switch session.step() {
        case .advanced:
            status.text = "\(session.completed) / \(session.total) characters"
        case .finished:
            finish("Done. Review your text before sending.")
        case .interrupted:
            finish(session.hasPendingTypo
                   ? "Stopped after a field/context change. Check the last letter for an unfinished typo."
                   : "Stopped because the field, cursor, or text changed.")
        }
    }

    @objc private func stopTyping() {
        let unfinished = session?.stop(repairPending: true) ?? false
        finish(unfinished ? "Stopped. Check the last letter for an unfinished typo."
                          : "Stopped. Start begins the whole text again.")
    }

    private func cancelForExternalChange() {
        guard timer != nil else { return }
        let unfinished = session?.stop(repairPending: false) ?? false
        finish(unfinished ? "Stopped. Check the last letter for an unfinished typo."
                          : "Stopped when the keyboard or field changed.")
    }

    @objc private func hostWillResignActive() { cancelForExternalChange() }

    private func finish(_ message: String) {
        timer?.invalidate()
        timer = nil
        currentDocument = nil
        setRunning(false)
        status.text = message
    }

    private func setRunning(_ running: Bool) {
        start.isEnabled = !running
        load.isEnabled = !running
        speed.isEnabled = !running
        typos.isEnabled = !running
    }

    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
}
