// Copyright © 2021 evan. All rights reserved.

import Foundation
import UIKit

/// A composition of which corners of a view should have rounded corners, and what their radii should be.\
/// We can't customize the radius of each corner individually due to how the CALayer's mask works.
/// - SeeAlso: `setCornerRadius(_ cornerRadius: CornerRadius)` in UIView+Utilities.
public struct CornerRadius : Equatable {
    /// The radius that will be applied to every corner described in the `corners` property.
    var radius: CGFloat
    /// Determines which corners the radius will be applied on.
    var corners: UIRectCorner

    public init(radius: CGFloat, corners: UIRectCorner = .allCorners) {
        (self.radius, self.corners) = (radius, corners)
    }

    public init(top radius: CGFloat) {
        (self.radius, self.corners) = (radius, [ .topLeft, .topRight ])
    }

    public init(bottom radius: CGFloat) {
        (self.radius, self.corners) = (radius, [ .bottomLeft, .bottomRight ])
    }
}
