// Copyright © 2021 evan. All rights reserved.

import PanModal

class BaseBottomSheetVC : BaseCollectionViewController, PanModalPresentable {
    private let style: Style
    var actionHandler: ActionClosure? // For `action` case, when user tap done button
    var dismissedHandler: ActionClosure?
    
    // MARK: Nested Types
    enum Style {
        enum Position { case left, right }
        
        case functions(title: String? = nil)
        case content(image: UIImage? = nil, imageURL: URL? = nil, imageViewBackgroundColor: UIColor? = nil, title: String? = nil, subtitle: String? = nil)
        case whiteCardStyleContent(title: String? = nil, subtitle: String? = nil)
        case explanation(title: String? = nil, position: Position = .right)
        case fullscreen(title: String? = nil, shouldDisplayDoneButton: Bool = false)
        case action(cancelRowStyle: CancelAndDoneRow.ActionStyle = .default, title: String? = nil, completionHandler: ActionClosure? = nil)
        case none

        var cancelRowStyle: CancelAndDoneRow.ActionStyle {
            switch self {
            case .action(let style, _, _): return style
            case .functions, .content, .whiteCardStyleContent, .explanation, .fullscreen, .none: return .default
            }
        }

        var title: String? {
            switch self {
            case .functions(let title): return title
            case .content(_, _, _, let title, _): return title
            case .whiteCardStyleContent(let title, _): return title
            case .explanation(let title, _): return title
            case .fullscreen(let title, _): return title
            case .action(_, let title, _): return title
            case .none: return nil
            }
        }

        var subtitle: String? {
            switch self {
            case .functions: return nil
            case .content(_, _, _, _, let subtitle): return subtitle
            case .whiteCardStyleContent(_, let subtitle): return subtitle
            case .explanation: return nil
            case .fullscreen: return nil
            case .action: return nil
            case .none: return nil
            }
        }

        var image: UIImage? {
            switch self {
            case .functions: return nil
            case .content(let image, _, _, _, _): return image
            case .whiteCardStyleContent: return nil
            case .explanation: return nil
            case .fullscreen: return nil
            case .action: return nil
            case .none: return nil
            }
        }

        var imageURL: URL? {
            switch self {
            case .functions: return nil
            case .content(_, let imageURL, _, _, _): return imageURL
            case .whiteCardStyleContent: return nil
            case .explanation: return nil
            case .fullscreen: return nil
            case .action: return nil
            case .none: return nil
            }
        }

        var imageViewBackgroundColor: UIColor? {
            switch self {
            case .functions: return nil
            case .content(_, _, let imageViewBackgroundColor, _, _): return imageViewBackgroundColor
            case .whiteCardStyleContent: return nil
            case .explanation: return nil
            case .fullscreen: return nil
            case .action: return nil
            case .none: return nil
            }
        }
    }

    // MARK: Settings
    class var automaticKeyboardManagement: Bool { return false }
    class var shouldRespondPanModalGestureRecognizer: Bool { return true }

    // MARK: Keyboard management
    private let observers = ObserverCollection()
    private var currentKeyboardHeight: CGFloat = 0
    private lazy var keyboardObserver = observers.addKeyboardObserver(handler: { [unowned self] in self.currentKeyboardHeight = $0.height })
    private var lastBounds: CGRect?

    // MARK: Initialization
    init(style: Style = .none) {
        self.style = style
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { 🔥 }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.removeFromSuperview()
        if case .none = style {
            view.addSubview(collectionView, pinningEdges: .all)
        } else {
            // Content
            view.addSubview(stackView, pinningEdgesToSafeArea: [ .left, .top, .right ], withInsets: UIEdgeInsets(horizontal: 16))
            view.addSubview(collectionView, pinningEdges: [ .left, .bottom, .right ])
            collectionView.topAnchor.constraint(equalTo: stackView.bottomAnchor).isActive = true
        }
        // Style
        switch style {
        case .functions, .content, .explanation, .action, .none:
            view.backgroundColor = .cabinetWhite
        case .whiteCardStyleContent:
            view.backgroundColor = .nonStandardColor(withRGBHex: 0xE9E9E9)
        case .fullscreen(let title, let shouldDisplayDoneButton):
            assert(self is SheetPresentable, "When using fullscreen style, the view controller must conform to `SheetPresentable`")
            view.backgroundColor = .cabinetWhite
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .plain) { [unowned self] in self.dismissSelf() }
            navigationItem.titleView = UILabel(text: title, font: .systemFont(ofSize: 17, weight: .semibold), color: .cabinetBlack, alignment: .center, lines: 0)
            if shouldDisplayDoneButton {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .done) { [unowned self] in self.dismissSelf() }
            }
        }
        // Keyboard
        if Self.automaticKeyboardManagement {
            keyboardObserver.keyboardWillHide = { [unowned self] in
                // When dismissing, we need to force the final keyboard height (zero)
                self.currentKeyboardHeight = 0
                self.panModalSetNeedsLayoutUpdate()
                self.panModalTransition(to: .longForm)
            }
            keyboardObserver.keyboardWillShow = { [unowned self] in
                self.panModalSetNeedsLayoutUpdate()
                self.panModalTransition(to: .longForm)
            }
        }
    }

    deinit { observers.removeAll() }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if stackView.bounds != lastBounds {
            lastBounds = stackView.bounds
            panModalSetNeedsLayoutUpdate()
            panModalTransition(to: .longForm)
        }
    }

    override func dismissSelf() {
        super.dismissSelf()
        dismissedHandler?()
    }
    
    // MARK: Components
    private lazy var cancelAndDoneRow: CancelAndDoneRow = {
        let result = CancelAndDoneRow()
        result.backgroundColor = .clear
        result.hideSeparators()
        result.title = style.title
        result.style = style.cancelRowStyle
        result.cancelHandler = { [unowned self] in self.dismissSelf() }
        result.doneHandler = { [unowned self] in self.actionHandler?(); self.dismissSelf() }
        return result
    }()

    private lazy var stackView: UIStackView = {
        switch style {
        case .functions(let title): break
        case .content, .whiteCardStyleContent: break
        case .explanation(let title, let position):
            let closeButton = UIButton()
            closeButton.setImage(#imageLiteral(resourceName: "18-close.pdf"), for: .normal)
            closeButton.constrainWidth(to: 18)
            closeButton.addTapHandler { [unowned self] in self.dismissSelf() }
            let views = position == .left ? [ closeButton, titleRow ] : [ titleRow, closeButton ]
            let stackView = UIStackView(axis: .horizontal, alignment: .center, spacing: 8, arrangedSubviews: views)
            stackView.constrainHeight(to: 62)
            return stackView
        case .fullscreen: break
        case .action: break
        case .none: break
        }
        
        let topRows: [BaseRow] = {
            switch style {
            case .functions(let title): return title == nil ? [] : [ titleRow ]
            case .content, .whiteCardStyleContent: return []
            case .explanation(let title, _): return title == nil ? [] : [ titleRow ]
            case .fullscreen: return []
            case .action: return [ cancelAndDoneRow ]
            case .none: return []
            }
        }()
        let result = UIStackView(axis: .vertical, arrangedSubviews: topRows)
        return result
    }()
    
    

    private(set) lazy var titleRow: TextRow = {
        let result: TextRow = {
            if let title = style.title {
                return TextRow(text: title, font: .systemFont(ofSize: 16, weight: .medium))
            } else {
                return TextRow(text: "", font: .systemFont(ofSize: 16, weight: .medium))
            }
        }()
        result.textColor = .cabinetBlack
        result.backgroundColor = .cabinetWhite
        result.edgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        result.hideSeparators()
        return result
    }()

    // MARK: PanModal
    var longFormHeight: PanModalHeight {
        if Self.automaticKeyboardManagement {
            return .contentHeight(collectionView.contentSize.height + currentKeyboardHeight + stackView.bounds.height)
        } else {
            // Default value
            return .contentHeight(collectionView.contentSize.height + stackView.bounds.height)
        }
    }

    func shouldRespond(to panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        return Self.shouldRespondPanModalGestureRecognizer
    }
    
    func panModalWillDismiss() {
        dismissedHandler?()
    }
}

extension PanModalPresentable where Self : BaseCollectionViewController {
    var panScrollable: UIScrollView? {
        // A workaround to fix keyboard issue when it's pan modal.
        collectionView.keyboardDismissMode = .onDrag
        return collectionView
    }

    var cornerRadius: CGFloat { return TTCornerRadius.large }
    var anchorModalToLongForm: Bool { return false }
    var showDragIndicator: Bool { return false }
}
