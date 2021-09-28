// Copyright © 2021 evan. All rights reserved.

final class CancelAndDoneRow : BaseRow {
    override class var height: RowHeight { return .fixed(54) }
    override var tintColor: UIColor? { didSet { handleTintColorChanged() } }
    var style: ActionStyle = .default { didSet { handleStyleChanged() } }

    var cancelHandler: ActionClosure?
    var doneHandler: ActionClosure?

    override func initialize() {
        super.initialize()
        let stackView = UIStackView(axis: .horizontal, distribution: .fill, spacing: 8, arrangedSubviews: [ cancelButton, titleLabel, doneButton ])
        contentView.addSubview(stackView, pinningEdges: .all, withInsets: UIEdgeInsets(horizontal: 0, vertical: 16))
        bottomSeparatorMode = .hide
    }

    private lazy var cancelButton: TTButton = {
        let button = TTButton(type: .custom, title: "取消", titleColor: .cabinetBlack) { [unowned self] in self.cancelHandler?() }
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.contentHorizontalAlignment = .left
        button.constrainWidth(to: 56)
        return button
    }()

    private lazy var doneButton: TTButton = {
        let button = TTButton(type: .custom, title: "确认", titleColor: .cabinetBlack) { [unowned self] in self.doneHandler?() }
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.contentHorizontalAlignment = .right
        button.constrainWidth(to: 56) // Must same as cancel button, otherwise the title is not centered.
        return button
    }()

    private lazy var titleLabel: UILabel = UILabel(font: .systemFont(ofSize: 16, weight: .bold), alignment: .center)

    // MARK: Nested type
    enum ActionStyle {
        /// Cancel and done
        case `default`
        /// Cancel only
        case cancel
        /// Done only
        case done
    }

    // MARK: Updating
    private func handleStyleChanged() {
        switch style {
        case .default: cancelButton.alpha = 1; doneButton.alpha = 1
        case .cancel: cancelButton.alpha = 1; doneButton.alpha = 0
        case .done: cancelButton.alpha = 0; doneButton.alpha = 1
        }
    }

    private func handleTintColorChanged() {
        [ cancelButton, doneButton ].forEach { $0.setTitleColor(tintColor, for: .normal) }
    }

    // MARK: Accessor
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }

    var cancelButtonTitle: String? {
        get { return cancelButton.title }
        set { cancelButton.title = newValue }
    }
    
    var cancelButtonTitleColor: UIColor? {
        get { return cancelButton.titleColor(for: .normal) }
        set { cancelButton.setTitleColor(newValue, for: .normal) }
    }
    
    var doneButtonTitle: String? {
        get { return doneButton.title }
        set { doneButton.title = newValue }
    }
    
    var doneButtonTitleColor: UIColor? {
        get { return doneButton.titleColor(for: .normal) }
        set { doneButton.setTitleColor(newValue, for: .normal) }
    }

    var titleColor: UIColor? {
        get { return titleLabel.textColor }
        set { titleLabel.textColor = newValue }
    }
}
