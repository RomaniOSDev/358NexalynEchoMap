import UIKit

enum KeyboardDismiss {
    private static let gestureName = "studio.keyboard.dismiss"

    static func install(in window: UIWindow?) {
        guard let window else { return }
        let alreadyInstalled = window.gestureRecognizers?.contains { $0.name == gestureName } ?? false
        guard !alreadyInstalled else { return }

        let tap = UITapGestureRecognizer(
            target: KeyboardDismissHandler.shared,
            action: #selector(KeyboardDismissHandler.handleTap(_:))
        )
        tap.name = gestureName
        tap.cancelsTouchesInView = false
        tap.delegate = KeyboardDismissHandler.shared
        window.addGestureRecognizer(tap)
    }
}

private final class KeyboardDismissHandler: NSObject, UIGestureRecognizerDelegate {
    static let shared = KeyboardDismissHandler()

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else { return }
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let view = touch.view else { return true }
        return !view.isTextInput
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}

private extension UIView {
    var isTextInput: Bool {
        var current: UIView? = self
        while let view = current {
            if view is UITextField || view is UITextView || view is UISearchBar {
                return true
            }
            current = view.superview
        }
        return false
    }
}
