// Copyright © 2021 evan. All rights reserved.

import UIKit

/// The base class for views intended for use as rows in BaseCollectionView.
open class BaseRow : UIView, SectionContentItem {
    // Swipe Menu Button
    public struct RowSwipeButton {
        public let title: String
        public let color: UIColor
        public let action: (Any) -> Void

        public init(title: String, color: UIColor, action: @escaping (Any) -> Void) {
            (self.title, self.color, self.action) = (title, color, action)
        }
    }

    // MARK: - Experimental Start -
    // This whole section should be deleted once we make BaseRow inherit from UIControl instead of UIView
    /// Whether this row should automatically track analytics events.
    /// - SeeAlso: analyticsIdentifier
    open var tracksAnalytics: Bool = false

    /// Set to customize the string used to identify this row when logging analytics events for it. Must be used alongside `tracksAnalytics`.
    /// - SeeAlso: tracksAnalytics
    open var analyticsIdentifier: String?

    /// Set to customize the additional properties to be logged alongside the analytics event for this row. Must be used alongside `tracksAnalytics`.
    /// - SeeAlso: tracksAnalytics
    open var analyticsAdditionalProperties: [String:Any]?
    // MARK: - Experimental End -

    open var removeSwipeButtonTitle: String { return NSLocalizedString("Delete", comment: "") }
    private let removeButtonTag: Int = 2424

    // Views
    public private(set) var contentView: UIView!
    private var accessoryView: UIImageView?
    private var topSeparatorView, bottomSeparatorView: UIView?
    private var highlightView: UIView?
    private var rightConstraint: NSLayoutConstraint!
    private var leftConstraint: NSLayoutConstraint!
    private var rightSwipeMenuLeftConstraint: NSLayoutConstraint?
    private var leftSwipeMenuRightConstraint: NSLayoutConstraint?
    private lazy var rightSwipeMenuStackView: UIStackView = UIStackView(axis: .horizontal, arrangedSubviews: [ removeButton ])
    private lazy var leftSwipeMenuStackView: UIStackView = {
        let buttons = leftSwipeButtons.map { createSwipeButton(title: $0.title, color: $0.color, action: $0.action) }
        return UIStackView(axis: .horizontal, arrangedSubviews: buttons)
    }()

    public lazy var removeButton: TTButton = {
        let button = createSwipeButton(title: removeSwipeButtonTitle, color: .red, action: { [unowned self] _ in self.removeItem() })
        button.tag = removeButtonTag
        return button
    }()

    public var leftSwipeButtons: [RowSwipeButton] = [] { didSet { handleLeftSwipeButtonsChanged() } }
    public var rightSwipeButtons: [RowSwipeButton] = [] { didSet { handleRightSwipeButtonsChanged() } }

    // Constants
    /// Calculates the correct right constraint constant for each size of accessory view image so that they're always trailing aligned.
    private var accessoryViewRightConstraintConstant: CGFloat {
        switch accessory {
        case .disclosureIndicator?, .dropdownOpen?, .dropdownClosed?, .plus?: return 32 // For images 16pt wide (16+16 = 32)
        case .checkmark?, .lock?: return 30 // For images 14pt wide (14+16 = 30)
        case .checkedCircle?, .warningExclamationCircle?: return 40 // For images 24pt wide (24+16 = 30)
        case .arrow?: return #imageLiteral(resourceName: "12-arrow.pdf").size.width + 16
        case .custom(let icon, _)?: return icon.size.width + 16
        case nil: return 0
        }
    }

    // General
    /// - Note: Should only be set by `BaseCollectionViewCell` internals.
    public weak var cell: BaseCollectionViewCell? { didSet { handleLayoutAttributesChanged() } }
    public var margin: UIEdgeInsets = .zero
    /// - Note: Should only be set by `BaseSection` internals.
    public weak var section: BaseSection?
    public var TTCornerRadius: CornerRadius? { didSet { handleCornerRadiusChanged() } }
    open var item: Any? {
        willSet { prepareForItemChange() }
        didSet { handleItemChanged() }
    }

    public var deletionHandler: DeletionHandler?
    open var selectionHandler: SelectionHandler?
    open var isEnabled = true { didSet { updateHighlight() } }
    private var highlightedBackgroundColor: UIColor = .gray { didSet { highlightView?.backgroundColor = highlightedBackgroundColor } }
    public var hitTestHandler: HitTestHandler?
    // Highlight
    open var isHighlightable: Bool = false { didSet { updateHighlight() } }
    public var isHighlighted: Bool = false { didSet { updateHighlight() } }
    public var isSelected: Bool = false { didSet { updateHighlight() } }
    // Separators
    public var topSeparatorMode: SeparatorMode = .auto { didSet { updateSeparatorVisibility(for: .top) } }
    public var bottomSeparatorMode: SeparatorMode = .auto { didSet { updateSeparatorVisibility(for: .bottom) } }
    // Accessory
    public var accessory: Accessory? { didSet { handleAccessoryChanged() } }
    public var hideAccessory: Bool {
        set { accessoryView?.isHidden = newValue; rightConstraint.constant = accessoryView != nil && !newValue ? -accessoryViewRightConstraintConstant : 0; layoutIfNeeded() }
        get { return accessoryView?.isHidden ?? true }
    }

    public var accessoryTintColor: UIColor? { didSet { handleAccessoryChanged() } }
    open var accessoryAlignment: Alignment { return .centerY(contentView.centerYAnchor) }
    // Standalone
    public var isStandalone: Bool { return cell == nil && collectionView == nil && window != nil }
    // Analytics
    /// Which namespace should be used when tracking events for this row.
    /// - SeeAlso: tracksAnalytics
    open var separatorsColor: UIColor = .nonStandardColor(withRGBHex: 0xE9E9E9) {
        didSet {
            topSeparatorView?.backgroundColor = separatorsColor
            bottomSeparatorView?.backgroundColor = separatorsColor
        }
    }

    open class var height: RowHeight { return .auto(estimate: 56) }
    open class var style: Style { return .regular }
    open class var nibName: String? { return nil }
    open class var margins: UIEdgeInsets { return .zero }
    /// - NOTE: Only the horizontal insets are taken into consideration.
    open class var separatorInsets: UIEdgeInsets { return .zero }
    /// Insets to be applied to the separator. Slightly less performant than its class counterpart `BaseRow.separatorInsets`, of which has a precedence over the instance one, i.e. if the class insets are different than zero, the instance insets are ignored.
    /// - SeeAlso: `BaseRow.separatorInsets`
    /// - NOTE: Only the horizontal insets are taken into consideration.
    /// - NOTE: The insets are positive on both ends, unlike `BaseRow.separatorInsets` behavior. This is intentional.
    public var separatorInsets: UIEdgeInsets = .zero { didSet { updateSeparatorVisibility(for: .top, updatingInsets: true); updateSeparatorVisibility(for: .bottom, updatingInsets: true) } }
    open class var separatorHeight: CGFloat { return 1 }
    open class var accessoryAlignmentOffset: CGFloat { return 0 }
    open class var isDeletable: Bool { return false }

    public var reuseIdentifier: String { return String(UInt(bitPattern: ObjectIdentifier(self))) }
    /// Non-nil if the cell is currently in the collection view (even if it might not be visible).
    public var indexPath: IndexPath? {
        return given(cell) { collectionView?.indexPath(for: $0) } ?? section?.indexPathForRow(at: 0, in: self)
    }

    public enum Style { case regular, separatorless, backgroundless }
    public enum Accessory { case disclosureIndicator, dropdownOpen, dropdownClosed, checkmark, lock, plus, checkedCircle, warningExclamationCircle, arrow, custom(icon: UIImage, ignoreTintColor: Bool = false) }
    public enum Alignment { case centerY(NSLayoutYAxisAnchor) } // Implement more as needed
    public enum SeparatorMode { case auto, show, hide }
    public typealias SelectionHandler = () -> Void
    public typealias DeletionHandler = (Any) -> Void
    public typealias ItemSelectionHandler = (Any) -> Void
    public typealias HitTestHandler = (CGPoint, UIEvent?) -> UIView?

    // MARK: Initialization
    public required init() { super.init(frame: .zero); initialize() }
    public required init?(coder: NSCoder) { super.init(coder: coder); initialize() }

    /// Can be overriden by subclasses to perform initialization code.
    ///
    /// Overriding implementation should always first call the superclass implementation.
    open func initialize() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = (type(of: self).style != .backgroundless) ? .cabinetWhite : nil
        contentView = loadContentView()
        contentView.backgroundColor = nil // Should generally not be set, because of highlighting
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        rightConstraint = contentView.rightAnchor.constraint(equalTo: rightAnchor)
        leftConstraint = contentView.leftAnchor.constraint(equalTo: leftAnchor)
        NSLayoutConstraint.activate([
            leftConstraint,
            rightConstraint,
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        if case .fixed(let height) = type(of: self).height {
            NSLayoutConstraint.activate([ heightAnchor.constraint(equalToConstant: height) ])
        }
        margin = type(of: self).margins

        if type(of: self).isDeletable {
            addGestureRecognizer(panRecognizer)
            rightSwipeMenuStackView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(rightSwipeMenuStackView)
            rightSwipeMenuLeftConstraint = rightSwipeMenuStackView.leftAnchor.constraint(equalTo: contentView.rightAnchor)
            NSLayoutConstraint.activate([
                rightSwipeMenuLeftConstraint!,
                rightSwipeMenuStackView.heightAnchor.constraint(equalTo: heightAnchor),
            ])
        }
        hideSeparators()
    }

    /// Can be overriden by subclass to load a create a custom content view.
    ///
    /// The default implementation load it from the nib specified by `nibName`, or creates a plain UIView if none is specified.
    open func loadContentView() -> UIView {
        if let nibName = type(of: self).nibName {
            let nib = UINib(nibName: nibName, bundle: nil)
            return nib.instantiate(withOwner: self).first as! UIView
        } else {
            return UIView()
        }
    }

    // MARK: General
    /// Called when the view's item is about to be set. To be overridden by subclasses. Must call the superclass implementation
    open func prepareForItemChange() {
        if isShowingSwipeMenu && (type(of: self).isDeletable || !leftSwipeButtons.isEmpty || !rightSwipeButtons.isEmpty) {
            hideSwipeMenu(animated: false)
        }
    }

    /// Called when the view's item was just set. To be overridden by subclasses.
    /// - Note: Subclasses should generally fail if the item is `nil` or of an unexpected type, i.e. force cast to the non-optional expected type.
    /// - Note: Subclasses should take into account the view might have been previously used for another item,
    /// and thus all properties (of e.g. labels) that could have been changed should be set to an explicit value.
    open func handleItemChanged() {}

    open func handleDidSelect() {}

    public func invalidateLayout() {
        if let collectionView = collectionView, let indexPath = indexPath {
            collectionView.invalidateRow(at: [ indexPath ])
        }
    }

    // MARK: Updating
    private func handleLeftSwipeButtonsChanged() {
        leftSwipeMenuStackView.removeSeparators()
        leftSwipeMenuStackView.removeFromSuperview()
        removePanGestureIfNeeded()
        guard !leftSwipeButtons.isEmpty else { return }
        addGestureRecognizer(panRecognizer)
        leftSwipeMenuStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leftSwipeMenuStackView)
        leftSwipeMenuRightConstraint = leftSwipeMenuStackView.rightAnchor.constraint(equalTo: contentView.leftAnchor)
        NSLayoutConstraint.activate([
            leftSwipeMenuRightConstraint!,
            leftSwipeMenuStackView.heightAnchor.constraint(equalTo: heightAnchor),
        ])
        leftSwipeMenuStackView.addSeparator(onEdges: .right)
    }

    private func handleRightSwipeButtonsChanged() {
        let buttons = rightSwipeButtons.map { createSwipeButton(title: $0.title, color: $0.color, action: $0.action) }
        rightSwipeMenuStackView.removeSeparators()
        rightSwipeMenuStackView.removeFromSuperview()
        removePanGestureIfNeeded()
        guard !buttons.isEmpty else { return }
        if type(of: self).isDeletable {
            rightSwipeMenuStackView = UIStackView(axis: .horizontal, arrangedSubviews: [ removeButton] + buttons)
        } else {
            rightSwipeMenuStackView = UIStackView(axis: .horizontal, arrangedSubviews: buttons)
        }
        addGestureRecognizer(panRecognizer)
        rightSwipeMenuStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rightSwipeMenuStackView)
        rightSwipeMenuLeftConstraint = rightSwipeMenuStackView.leftAnchor.constraint(equalTo: contentView.rightAnchor)
        NSLayoutConstraint.activate([
            rightSwipeMenuLeftConstraint!,
            rightSwipeMenuStackView.heightAnchor.constraint(equalTo: heightAnchor),
        ])
        rightSwipeMenuStackView.addSeparator(onEdges: .left)
    }

    public func handleLayoutAttributesChanged() {
        updateSeparatorVisibility(for: .top)
        updateSeparatorVisibility(for: .bottom)
        handleCornerRadiusChanged()
    }

    private func handleCornerRadiusChanged() {
        guard let TTCornerRadius = TTCornerRadius else { return }
        setCornerRadius(TTCornerRadius)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        handleCornerRadiusChanged()
    }

    open override func didMoveToWindow() {
        if isStandalone { handleLayoutAttributesChanged() }
    }

    public func modifyPreferredLayoutAttributes(_ layoutAttributes: UICollectionViewLayoutAttributes) {}

    // MARK: Interaction
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        assert(!isMultipleTouchEnabled)
        super.touchesBegan(touches, with: event)
        if isStandalone { setIsHighlighted(true, animated: false) }
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        assert(!isMultipleTouchEnabled)
        super.touchesEnded(touches, with: event)
        if isStandalone {
            setIsHighlighted(false, animated: true)
            handleDidSelectRow(at: 0)
        }
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        assert(!isMultipleTouchEnabled)
        super.touchesEnded(touches, with: event)
        if isStandalone { setIsHighlighted(false, animated: true) }
    }

    // MARK: Highlight
    private func setIsHighlighted(_ isHighlighted: Bool, animated: Bool) {
        if animated {
            UIView.animate(withDuration: TTDuration.default) { self.isHighlighted = isHighlighted }
        } else {
            self.isHighlighted = isHighlighted
        }
    }

    private func updateHighlight() {
        let showHighlight = isEnabled && isHighlightable && (isHighlighted || isSelected)
        if showHighlight {
            let highlightView = lazy(&self.highlightView) {
                let view = UIView(frame: bounds) // Set frame to prevent initial animation
                addSubview(view, pinningEdges: .all)
                sendSubviewToBack(view)
                return view
            }
            highlightView.backgroundColor = highlightedBackgroundColor
            highlightView.layer.cornerRadius = layer.cornerRadius
            highlightView.alpha = 1
        } else {
            highlightView?.alpha = 0
        }
    }

    // MARK: Separators
    private func updateSeparatorVisibility(for side: VerticalSide, updatingInsets: Bool = false) {
        // Determine visibility
        let visible: Bool
        let separatorMode = (side == .top) ? topSeparatorMode : bottomSeparatorMode
        switch separatorMode {
        case .auto:
            if isStandalone {
                visible = (type(of: self).style == .regular)
            } else {
                visible = given(cell?.layoutAttributes) { side == .top ? $0.topSeparator : $0.bottomSeparator } ?? false
            }
        case .show: visible = true
        case .hide: visible = false
        }
        // Apply
        switch side {
        case .top: setVisible(visible, for: &topSeparatorView, side: .top, forcingReload: updatingInsets)
        case .bottom: setVisible(visible, for: &bottomSeparatorView, side: .bottom, forcingReload: updatingInsets)
        }
    }

    public func hideSeparators() {
        bottomSeparatorMode = .hide
        topSeparatorMode = .hide
    }

    private func setVisible(_ visible: Bool, for separator: inout UIView?, side: VerticalSide, forcingReload: Bool = false) {
        if visible {
            if forcingReload {
                separator?.removeFromSuperview()
                separator = nil
            }
            let separator = lazy(&separator) {
                // Create separator
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                addSubview(view)
                let separatorInsets: UIEdgeInsets
                if type(of: self).separatorInsets != .zero {
                    separatorInsets = type(of: self).separatorInsets
                    NSLayoutConstraint.activate([
                        view.leftAnchor.constraint(equalTo: leftAnchor, constant: separatorInsets.left),
                        view.rightAnchor.constraint(equalTo: rightAnchor, constant: separatorInsets.right),
                        (side == .top) ? view.topAnchor.constraint(equalTo: topAnchor) : view.bottomAnchor.constraint(equalTo: bottomAnchor),
                        view.heightAnchor.constraint(equalToConstant: type(of: self).separatorHeight / UIScreen.main.scale),
                    ])
                } else {
                    separatorInsets = self.separatorInsets
                    NSLayoutConstraint.activate([
                        view.leftAnchor.constraint(equalTo: leftAnchor, constant: separatorInsets.left),
                        view.rightAnchor.constraint(equalTo: rightAnchor, constant: -separatorInsets.right),
                        (side == .top) ? view.topAnchor.constraint(equalTo: topAnchor) : view.bottomAnchor.constraint(equalTo: bottomAnchor),
                        view.heightAnchor.constraint(equalToConstant: type(of: self).separatorHeight / UIScreen.main.scale),
                    ])
                }
                view.backgroundColor = separatorsColor
                return view
            }
            separator.isHidden = false
        } else {
            separator?.isHidden = true // Don't force lazy instantiation
        }
    }

    // MARK: Accessory
    private func handleAccessoryChanged() {
        if let accessory = accessory {
            let accessoryView = lazy(&self.accessoryView) {
                let view = UIImageView()
                view.translatesAutoresizingMaskIntoConstraints = false
                addSubview(view)
                let alignmentConstraint: NSLayoutConstraint = {
                    switch accessoryAlignment {
                    case .centerY(let anchor): return view.centerYAnchor.constraint(equalTo: anchor, constant: type(of: self).accessoryAlignmentOffset)
                    }
                }()
                NSLayoutConstraint.activate([
                    view.leftAnchor.constraint(equalTo: contentView.rightAnchor),
                    alignmentConstraint,
                ])
                return view
            }
            let (icon, tintColor, ignoreTintColor) = accessoryIconAndColor(for: accessory)
            accessoryView.image = icon.withRenderingMode(ignoreTintColor ? .alwaysOriginal : .alwaysTemplate)
            accessoryView.tintColor = tintColor
            accessoryView.isHidden = false
            rightConstraint.constant = -accessoryViewRightConstraintConstant
            rightSwipeMenuLeftConstraint?.constant = accessoryViewRightConstraintConstant
        } else {
            accessoryView?.image = nil
            accessoryView?.isHidden = true // Don't force lazy instantiation
            rightConstraint.constant = 0
            rightSwipeMenuLeftConstraint?.constant = 0
        }
    }

    private func accessoryIconAndColor(for accessory: Accessory) -> (UIImage, UIColor, Bool) {
        switch accessory { // Note that some of these aren't template images yet
        case .disclosureIndicator: return (#imageLiteral(resourceName: "12-arrow.pdf"), .white, true)
        case .lock: return (#imageLiteral(resourceName: "12-arrow.pdf"), accessoryTintColor ?? .white, false)
        case .dropdownOpen: return (#imageLiteral(resourceName: "dropdown-up"), accessoryTintColor ?? .white, false)
        case .dropdownClosed: return (#imageLiteral(resourceName: "dropdown-down"), accessoryTintColor ?? .white, false)
        case .checkmark: return (#imageLiteral(resourceName: "16-checkmark.pdf"), accessoryTintColor ?? .white, true)
        case .plus: return (#imageLiteral(resourceName: "12-arrow.pdf"), accessoryTintColor ?? .white, false)
        case .checkedCircle: return (#imageLiteral(resourceName: "12-arrow.pdf"), accessoryTintColor ?? .white, false)
        case .warningExclamationCircle: return (#imageLiteral(resourceName: "12-arrow.pdf"), accessoryTintColor ?? .white, false)
        case .arrow: return (#imageLiteral(resourceName: "12-arrow.pdf"), accessoryTintColor ?? .white, true)
        case .custom(let image, let ignoreTintColor): return (image, accessoryTintColor ?? .white, ignoreTintColor)
        }
    }

    // MARK: Content Item
    public final var rowCount: Int { return 1 }

    public final func registerCells() {
        collectionView?.register(BaseCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }

    public final func cellForRow(at index: Int) -> UICollectionViewCell {
        assert(index == 0)
        let cell = collectionView!.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath!) as! BaseCollectionViewCell
        cell.row = self
        return cell
    }

    public final func layoutInfoForRow(at index: Int) -> BaseRow.LayoutInfo {
        assert(index == 0)
        let rowType = type(of: self)
        let uniqueID = String(UInt(bitPattern: ObjectIdentifier(self)))
        return LayoutInfo(uniqueID: uniqueID, height: computeHeight(), margins: margin, cornerRadius: TTCornerRadius, style: rowType.style)
    }

    public final func handleDidSelectRow(at index: Int) {
        assert(index == 0)
        guard isEnabled else { return }
        guard !isShowingSwipeMenu else { return hideSwipeMenu() }
        hideSwipeMenuOnOtherRowsIfNeeded()
        if let selectionHandler = selectionHandler {
            selectionHandler()
        } else {
            handleDidSelect()
        }
    }

    public func indexForRow(at indexInItem: Int, in item: SectionContentItem) -> Int? {
        guard item === self, !isHidden, indexInItem == 0 else { return nil }
        return indexInItem
    }

    // MARK: Swipe actions
    public func updateRemoveSwipeButtonTitle() {
        for button in rightSwipeMenuStackView.arrangedSubviews where button.tag == removeButtonTag {
            (button as? TTButton)?.setTitle(removeSwipeButtonTitle, for: .normal)
        }
    }

    private func createSwipeButton(title: String, color: UIColor, action: @escaping (Any) -> Void) -> TTButton {
        let action = TTButtonAction(title: title, color: .white) { [unowned self] in action(self.item!) } // Should always have a value
        let button = TTButton(action: action)
        button.contentEdgeInsets = UIEdgeInsets(horizontal: 16)
        button.backgroundColor = color
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
        return button
    }

    private struct Pan {
        let startPoint: CGFloat
        let startOffset: CGFloat
        var previousPoint: CGFloat
        var currentPoint: CGFloat { didSet { previousPoint = oldValue } }
        var lastDelta: CGFloat { return currentPoint - previousPoint }
        var delta: CGFloat { return currentPoint - startPoint }

        init(point: CGFloat, offset: CGFloat) {
            self.startPoint = point
            self.startOffset = offset
            self.currentPoint = point
            self.previousPoint = point
        }
    }

    private lazy var panRecognizer: UIPanGestureRecognizer = {
        let panRecognizer = UIPanGestureRecognizer()
        panRecognizer.delegate = self
        panRecognizer.addTarget(self, action: #selector(panGestureAction(_:)))
        return panRecognizer
    }()

    private var isShowingSwipeMenu: Bool { return contentHorizontalOffset != 0 }
    private var pan: Pan?
    private var contentHorizontalOffset: CGFloat = 0 {
        didSet {
            // Constraints might not be set
            rightConstraint?.constant = (accessoryView != nil && !hideAccessory ? -accessoryViewRightConstraintConstant : 0) + contentHorizontalOffset
            leftConstraint?.constant = contentHorizontalOffset
        }
    }

    private func removeItem() {
        hideSwipeMenu()
        guard let item = item else { return }
        deletionHandler?(item)
    }

    public func hideSwipeMenu(animated: Bool = true) {
        contentHorizontalOffset = 0
        layoutIfNeeded(animated: animated)
    }

    public func hideSwipeMenuOnOtherRowsIfNeeded() {
        // Is there a better way to handle this ? disable removing on other rows, if any
        collectionView?.visibleCells.compactMap { ($0 as? BaseCollectionViewCell)?.row }.forEach { $0.hideSwipeMenu() }
    }

    @objc private func panGestureAction(_ panGesture: UIPanGestureRecognizer) {
        let hasLeftSwipeButtons = !leftSwipeButtons.isEmpty
        let hasRightSwipeButtons = !rightSwipeButtons.isEmpty
        guard isEnabled && (deletionHandler != nil || hasLeftSwipeButtons || hasRightSwipeButtons) else { return }
        let point = panGesture.translation(in: self).x
        switch panGesture.state {
        case .possible: break
        case .began:
            pan = Pan(point: point, offset: contentHorizontalOffset)
            hideSwipeMenuOnOtherRowsIfNeeded()
        case .changed:
            pan?.currentPoint = point
            guard let pan = pan else { return }
            let targetOffset = pan.startOffset + pan.delta
            switch targetOffset {
            case 0: contentHorizontalOffset = 0
            case ..<0:
                if hasRightSwipeButtons || deletionHandler != nil {
                    contentHorizontalOffset = targetOffset.constrained(to: -rightSwipeMenuStackView.frame.width...0)
                }
            default:
                if hasLeftSwipeButtons {
                    contentHorizontalOffset = targetOffset.constrained(to: 0...leftSwipeMenuStackView.frame.width)
                }
            }
            layoutIfNeeded(animated: true)
        case .ended, .cancelled, .failed:
            guard let pan = pan else { return }
            contentHorizontalOffset = {
                // If user swipe just a little then release finger, we just cancel the swipe.
                guard abs(contentHorizontalOffset) > 40 else { return 0 }
                // If user has already swiped to one direction, we shouldn't allow it swiping to another direction when user dismiss it qucikly.
                if (pan.startOffset < 0 && pan.lastDelta > 0) || (pan.startOffset > 0 && pan.lastDelta < 0) {
                    return 0
                }
                // Determine which direction and how many points should swipe to.
                return pan.lastDelta > 0 ?
                    (hasLeftSwipeButtons ? leftSwipeMenuStackView.frame.width : 0) :
                    ((hasRightSwipeButtons || deletionHandler != nil) ? -rightSwipeMenuStackView.frame.width : 0)
            }()
            layoutIfNeeded(animated: true)
            self.pan = nil
        @unknown default: break
        }
    }

    private func removePanGestureIfNeeded() {
        guard deletionHandler == nil && leftSwipeButtons.isEmpty && rightSwipeButtons.isEmpty else { return }
        if gestureRecognizers?.contains(panRecognizer) == true {
            removeGestureRecognizer(panRecognizer)
        }
    }

    private func layoutIfNeeded(animated: Bool) {
        guard animated else { return layoutIfNeeded() }
        UIView.animate(withDuration: TTDuration.default, delay: 0, options: .curveEaseInOut, animations: { self.layoutIfNeeded() })
    }

    // Overridable by subclasses to provide explicit height computation
    open func computeHeight() -> RowHeight {
        if let item = item { return type(of: self).computeHeight(forItem: item) }
        return type(of: self).height
    }

    open class func computeHeight(forItem item: Any) -> RowHeight { return height }
}

// MARK: UIGestureRecognizerDelegate
extension BaseRow : UIGestureRecognizerDelegate {
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let gesture = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        let velocity = gesture.velocity(in: self)
        return abs(velocity.x) > abs(velocity.y)
    }
}
