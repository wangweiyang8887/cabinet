// Copyright © 2021 evan. All rights reserved.

import UIKit

// Hack needed to fix a bug with Objective-C bridging on Xcode 10+
@objc(TTButton) open class TTButton : UIButton {
    /// Possible styles for the button when highlighted
    ///
    /// - alphaChannel: animates the alpha of the button to 0.5 when highlighted or to 1 otherwise
    /// - custom: closure with isHighlighted and the button itself to customize highlighting styles
    /// - none: iOS default style
    public enum HighlightStyle {
        case alphaChannel
        case custom(handler: (_ isHighlighted: Bool, _ button: TTButton) -> ActionClosure)
        case none
    }

    private var lastHighlightedValue: Bool?
    open override var isHighlighted: Bool {
        didSet {
            guard !adjustsImageWhenHighlighted, isHighlighted != lastHighlightedValue else { return }
            switch highlightStyle {
            case .alphaChannel: UIView.animate(withDuration: 0.1) { self.alpha = self.isHighlighted ? 0.5 : 1 }
            case .custom(let handler): handler(isHighlighted, self)()
            case .none: break
            }
            lastHighlightedValue = isHighlighted
        }
    }
    
    open override var isUserInteractionEnabled: Bool {
        didSet {
            alpha = isUserInteractionEnabled ? 1 : 0.7
        }
    }

    /// Defines the style of the button when highlighted
    open var highlightStyle: HighlightStyle = .alphaChannel

    /// Customizes the total tappable area size of a button.
    /// You usually want to set a value at least higher than 33, but ideally higher than or equal to 40, for both width and height, due to Apple User Interface Guidelines.
    /// Use this property with caution - make sure the tappable areas of this button doesn't colide with other components' tappable areas, otherwise you'll experience unexpected behavior.
    public var tappableAreaSize: CGSize? {
        didSet {
            if tappableAreaSize != nil {
                tappableAreaPadding = nil
            }
            updateDebugTappableAreaSizeLayer()
        }
    }

    /// Defines the offset of the tappable area of the button.
    public var tappableAreaPadding: UIEdgeInsets? {
        didSet {
            if tappableAreaPadding != nil {
                tappableAreaSize = nil
            }
            updateDebugTappableAreaSizeLayer()
        }
    }

    /// Whether to show the tappable area around the button set by `tappableAreaSize` or `tappableAreaPadding`.
    public var isDebugTappableAreaVisible: Bool = false { didSet { updateDebugTappableAreaSizeLayer() } }
    private var debugTappableAreaSizeLayer: UIView?

    /// Adjust the image and the button's title label vertically centered
    public func adjustImageAndTitleVertically() {
        contentHorizontalAlignment = .left
        contentVerticalAlignment = .center
        let offset: CGFloat = 10.0
        let buttonSize = frame.size
        if let titleLabel = titleLabel, let imageView = imageView, let buttonTitle = titleLabel.text, let image = imageView.image {
            let titleString = NSString(string: buttonTitle)
            let titleSize = titleString.size(withAttributes:[ NSAttributedString.Key.font : titleLabel.font! ])
            let buttonImageSize = image.size
            let topImageOffset = (buttonSize.height - (titleSize.height + buttonImageSize.height + offset)) / 2
            let leftImageOffset = (buttonSize.width - buttonImageSize.width) / 2
            imageEdgeInsets = UIEdgeInsets(top: topImageOffset - 8.0, left: leftImageOffset, bottom: 0, right: 0)
            let titleTopOffset = topImageOffset + offset + buttonImageSize.height
            let leftTitleOffset = (buttonSize.width - titleSize.width) / 2 - image.size.width
            titleEdgeInsets = UIEdgeInsets(top: titleTopOffset, left: leftTitleOffset, bottom: 0, right: 0)
            titleLabel.textAlignment = .center
            titleLabel.center = frame.center
            imageView.center = frame.center
            layoutIfNeeded()
        }
    }
    
    /// Flip button's title and image
    public func forceButtonLayoutDirection(with offset: CGFloat = 4.0) {
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            semanticContentAttribute = .forceLeftToRight
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: offset)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: offset, bottom: 0, right: 0)
        } else {
            semanticContentAttribute = .forceRightToLeft
            imageEdgeInsets = UIEdgeInsets(top: 0, left: offset, bottom: 0, right: 0)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: offset)
        }
    }

    // MARK: Lifecycle
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard isDebugTappableAreaVisible else { return }
        debugTappableAreaSizeLayer?.frame = calculateTappableFrame()
    }

    // MARK: Update
    private func updateDebugTappableAreaSizeLayer() {
        debugTappableAreaSizeLayer?.removeFromSuperview()
        debugTappableAreaSizeLayer = nil
        guard isDebugTappableAreaVisible else { return }
        debugTappableAreaSizeLayer = UIView(frame: calculateTappableFrame())
        debugTappableAreaSizeLayer!.backgroundColor = UIColor.blue.withAlphaComponent(0.3)
        debugTappableAreaSizeLayer!.isUserInteractionEnabled = false
        addSubview(debugTappableAreaSizeLayer!)
        sendSubviewToBack(debugTappableAreaSizeLayer!)
    }

    private func calculateTappableFrame() -> CGRect {
        if let tappableAreaSize = tappableAreaSize {
            return CGRect(center: bounds.center, size: tappableAreaSize)
        } else if let tappableAreaPadding = self.tappableAreaPadding {
            return CGRect(x: bounds.origin.x - tappableAreaPadding.left, y: bounds.origin.y - tappableAreaPadding.top, width: bounds.size.width + tappableAreaPadding.left + tappableAreaPadding.right, height: bounds.size.height + tappableAreaPadding.top + tappableAreaPadding.bottom)
        }
        return bounds
    }

    // MARK: Interaction
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let correctedRect = calculateTappableFrame()
        return correctedRect.contains(point)
    }

    open override func sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        super.sendAction(action, to: target, for: event)
        // TODO: Filter the UIEvents and maybe convert them to UIControl.Event (possibly only .touchUpInside)
        handleActionReceived(event: event)
    }

    /// Override to add extra functionality alongside touch up inside events. You must call super upon overriding because the default implementation tracks analytics events.
    open func handleActionReceived(event: UIEvent?) {}
}
