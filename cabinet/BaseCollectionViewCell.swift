// Copyright © 2021 evan. All rights reserved.

import UIKit

public final class BaseCollectionViewCell : UICollectionViewCell {
    public private(set) var layoutAttributes: BaseCollectionViewLayoutAttributes?
    private var widthConstraint: NSLayoutConstraint!
    public var row: BaseRow? { didSet { if row != oldValue { handleRowChanged(oldValue: oldValue) } } }
    public override var isHighlighted: Bool { didSet { row?.isHighlighted = isHighlighted } }
    public override var isSelected: Bool { didSet { row?.isSelected = isSelected } }

    // MARK: Initialization
    public override init(frame: CGRect) { super.init(frame: frame); initialize() }
    public required init?(coder: NSCoder) { super.init(coder: coder); initialize() }

    private func initialize() {
        translatesAutoresizingMaskIntoConstraints = false
        // Use a non-required bottom constraint for the content view to prevent constraint conlicts during auto cell sizing.
        contentView.translatesAutoresizingMaskIntoConstraints = false
        widthConstraint = contentView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor).with(priority: .pseudoRequired),
            widthConstraint,
        ])
    }

    // MARK: Updating
    private func handleRowChanged(oldValue: BaseRow?) {
        // Remove old
        oldValue?.cell = self
        oldValue?.removeFromSuperview()
        // Add new
        if let row = row {
            row.removeFromSuperview()
            contentView.addSubview(row, pinningEdges: .all)
            row.TTCornerRadius = layoutAttributes?.cornerRadius
            row.cell = self
            row.isHighlighted = isHighlighted
            row.isSelected = isSelected
        }
    }

    public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        self.layoutAttributes = (layoutAttributes as! BaseCollectionViewLayoutAttributes)
        widthConstraint.constant = layoutAttributes.size.width
        row?.TTCornerRadius = self.layoutAttributes!.cornerRadius
        row?.handleLayoutAttributesChanged()
        guard let tableTransform = row?.collectionView?.transform else { return }
        transform = tableTransform
    }

    public override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let result = super.preferredLayoutAttributesFitting(layoutAttributes)
        row?.modifyPreferredLayoutAttributes(result)
        return result
    }
}

