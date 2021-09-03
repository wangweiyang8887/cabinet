// Copyright © 2021 evan. All rights reserved.

public final class KeyboardObserver : NSObject {
    /// This class only serves as a UIKeyboard position tracker on the screen, when the UIScrollView is dragging and dismissing the keyboard
    /// These observers get notified and we follow that change
    private class KeyboardTrackingView : UIView {
        var positionChangedCallback: (() -> Void)?
        // Must be `weak`, shouldn't hold a strong reference for its superview.
        // otherwise it can't be deallocated, and it also causes the keyboard to get stuck.
        weak var observedView: UIView?
        private let observers = ObserverCollection()

        deinit { observers.removeAll() }

        override func didMoveToSuperview() {
            observers.removeAll()
            observedView = self.superview
            if let observedView = observedView {
                observers.addKVOObserver(on: observedView, for: [ #keyPath(UIView.center) ], initialUpdate: false) { [weak self] _ in
                    self?.positionChangedCallback?()
                }
            }
            super.didMoveToSuperview()
        }
    }

    private lazy var keyboardTrackerView: KeyboardTrackingView = {
        let trackingView = KeyboardTrackingView()
        trackingView.positionChangedCallback = { [weak self] in
            self?.onChangePosition?()
        }
        return trackingView
    }()

    /// A view which purpose is to track the keyboard position in the screen
    public var trackingView: UIView { return self.keyboardTrackerView }

    private let notifications = Observers()
    private var keyboardHeight: CGFloat = 0

    public typealias KeyboardChangeFrameType = (CGRect) -> Void
    public typealias KeyboardChangePositionType = ActionClosure

    /// Use this closure to make the changes before the animation take place, the endFrame is provided
    public var onKeyboardWillChange: KeyboardChangeFrameType?

    /// This closure will be animated alongside the keyboard changes
    public var animationBlock: ActionClosure?

    /// This closure gets called everytime the keyboard changes position
    public var onChangePosition: KeyboardChangePositionType?

    /// This closure gets called every time the keyboard will be hidden
    public var keyboardWillHide: ActionClosure?

    /// This closure gets called every time the keyboard will be shown
    public var keyboardWillShow: ActionClosure?

    deinit { notifications.removeAll() }

    public override init() {
        super.init()
        // This frame's used to guard against unnecessary changes.
        var lastFrame: CGRect?
        notifications.when(UIResponder.keyboardWillShowNotification) { [unowned self] _ in
            self.keyboardWillShow?()
        }
        notifications.when(UIResponder.keyboardWillChangeFrameNotification) { [unowned self] in
            lastFrame = self.keyboardNotification(notification: $0, lastFrame: lastFrame)
        }
        notifications.when(UIResponder.keyboardWillHideNotification) { [unowned self] in
            lastFrame = self.keyboardNotification(notification: $0, lastFrame: lastFrame)
            self.keyboardWillHide?()
        }
    }

    private func keyboardNotification(notification: Notification, lastFrame: CGRect?) -> CGRect {
        guard let userInfo = notification.userInfo else { return .zero }

        let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        guard lastFrame != endFrame else { return endFrame }

        keyboardHeight = endFrame.height
        onKeyboardWillChange?(endFrame)

        let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        if let rawAnimationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int, let animationCurve = UIView.AnimationCurve(rawValue: rawAnimationCurve) {
            UIView.animate(withDuration: duration, delay: 0, options: [ .beginFromCurrentState, .allowUserInteraction ], animations: {
                UIView.setAnimationCurve(animationCurve)
                self.animationBlock?()
            })
        } else {
            self.animationBlock?()
        }
        return endFrame
    }
}
