// Copyright © 2021 evan. All rights reserved.

extension UIAlertController {
    @objc
    public enum UIStyle : Int { case unspecified, light, dark }

    /// Present the UIAlertController only if there isn't another UIAlertController visible on the screen.
    ///
    /// - Parameter presentingViewController: The view controller from where to present the UIAlertcontroller from. It's nullable so we can pass weak references more easily, but if it's nil the UIAlertController won't be presented.
    @objc
    public func present(on presentingViewController: UIViewController, in uiStyle: UIStyle = .light) {
        guard !(presentingViewController is UIAlertController) else { return }
        if let popoverController = popoverPresentationController { // For iPad support
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(origin: view.center, size: .zero)
            popoverController.permittedArrowDirections = []
        }
        actions.forEach { action in
            action.setValue(action.style == .destructive ? UIColor.red : UIColor.cabinetDarkBlue, forKey: "titleTextColor")
        }
        if #available(iOS 13.0, *) {
            given(UIUserInterfaceStyle(rawValue: uiStyle.rawValue)) { overrideUserInterfaceStyle = $0 }
        } else {
            // Doesn't support
        }
        DispatchQueue.main.async {
            // Retaining self is necessary because a weak instance of self would have been deallocated by the time this was called
            presentingViewController.present(self, animated: true, completion: nil)
        }
    }

    public static func presentConfirmationAlert(title: String? = nil, message: String? = nil, style: UIAlertController.Style = .alert, confirmationTitle: String = NSLocalizedString("Ok", comment: ""), in uiStyle: UIStyle = .light, action: @escaping ActionClosure) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: style)
        vc.addAction(.cancel)
        let confirmAction = UIAlertAction(title: confirmationTitle, style: .default) { _ in action() }
        vc.addAction(confirmAction)
        vc.preferredAction = confirmAction
        vc.present(on: UIViewController.current(), in: uiStyle)
    }

    @objc
    public static func presentAlert(title: String? = nil, message: String? = nil, style: UIAlertController.Style = .alert, actions: [UIAlertAction] = [], on viewController: UIViewController = UIViewController.current(), in uiStyle: UIStyle = .light) {
        let alertController: UIAlertController
        switch style {
        case .alert:
            alertController = UIAlertController(title: title == nil ? "" : title, message: message, preferredStyle: style)
        case .actionSheet:
            alertController = UIAlertController(title: title?.trimmedNilIfEmpty, message: message, preferredStyle: style)
        @unknown default: 🔥
        }
        actions.isEmpty ? alertController.addAction(.ok()) : actions.forEach { alertController.addAction($0) }
        alertController.present(on: viewController, in: uiStyle)
    }
}

extension UIAlertAction {
    public static let cancel: UIAlertAction = .cancel()

    public class func ok(action: ActionClosure? = nil) -> UIAlertAction {
        return UIAlertAction(title: "确认", style: .default) { _ in action?() }
    }

    public static func cancel(_ action: ActionClosure? = nil) -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .cancel) { _ in action?() }
    }
}

