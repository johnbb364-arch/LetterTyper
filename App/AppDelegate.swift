import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = EditorViewController()
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}

final class EditorViewController: UIViewController {
    private let editor = UITextView()
    private let status = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let title = UILabel()
        title.text = "Letter Typer"
        title.font = .preferredFont(forTextStyle: .largeTitle)
        let instructions = UILabel()
        instructions.numberOfLines = 0
        instructions.font = .preferredFont(forTextStyle: .body)
        instructions.text = "1. Add Letter Typer in Settings → General → Keyboard → Keyboards → Add New Keyboard.\n2. Enable Allow Full Access for clipboard import. This app has no network code.\n3. Write text below and tap Copy for keyboard.\n4. In Notes, switch keyboards with the globe, tap Load copied text, then Start."
        editor.font = .preferredFont(forTextStyle: .body)
        editor.backgroundColor = .secondarySystemBackground
        editor.layer.cornerRadius = 12
        editor.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        editor.text = UserDefaults.standard.string(forKey: "draft") ?? "Hello! This is my letter-by-letter keyboard."
        let copy = UIButton(type: .system)
        copy.setTitle("Copy for keyboard", for: .normal)
        copy.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        copy.addTarget(self, action: #selector(copyText), for: .touchUpInside)
        status.numberOfLines = 0
        status.text = "Drafts stay on this device. Test in a blank Note first."
        status.font = .preferredFont(forTextStyle: .footnote)
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        let stack = UIStackView(arrangedSubviews: [title, instructions, editor, copy, status])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -12),
            stack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -40),
            editor.heightAnchor.constraint(equalToConstant: 200),
            copy.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
    }

    @objc private func copyText() {
        guard !editor.text.isEmpty, editor.text.count <= 10_000 else {
            status.text = "Enter between 1 and 10,000 characters."
            return
        }
        UserDefaults.standard.set(editor.text, forKey: "draft")
        UIPasteboard.general.setItems([[UIPasteboard.typeAutomatic: editor.text ?? ""]],
                                      options: [.localOnly: true])
        editor.resignFirstResponder()
        status.text = "Copied. Open your target app, select Letter Typer, then Load copied text."
    }
}
