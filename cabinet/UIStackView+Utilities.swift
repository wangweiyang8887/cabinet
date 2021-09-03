// Copyright © 2021 evan. All rights reserved.

import UIKit

extension UIStackView {
    @objc public convenience init(axis: NSLayoutConstraint.Axis, distribution: Distribution = .fill, alignment: Alignment = .fill, spacing: CGFloat = 0, arrangedSubviews: [UIView] = []) {
        self.init(arrangedSubviews: arrangedSubviews)
        (self.axis, self.distribution, self.alignment, self.spacing) = (axis, distribution, alignment, spacing)
    }
    
    public func move(view: UIView, to index: Int) {
        guard let v = arrangedSubviews.first(where: { $0 === view }) else { return }
        removeArrangedSubview(v)
        setNeedsLayout()
        layoutIfNeeded()
        insertArrangedSubview(v, at: index)
        setNeedsLayout()
    }
}
