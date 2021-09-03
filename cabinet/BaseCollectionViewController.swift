// Copyright © 2021 evan. All rights reserved.

import UIKit

class BaseCollectionViewController : BaseViewController {
    /// The core of the current class
    public lazy var collectionView: BaseCollectionView = {
        precondition(Self.collectionViewClass.isSubclass(of: BaseCollectionView.self), "`collectionViewClass` must be a subclass of `BaseCollectionView`.")
        return Self.collectionViewClass.init() as! BaseCollectionView
    }()

    private let observers = ObserverCollection()
    private var cachedBottomInset: CGFloat = 0
    public var keyboardFrameInWindow = CGRect.zero

    // MARK: Settings
    public class var shouldRespondToKeyboardChanges: Bool { return true }
    public class var autoManageNavBar: Bool { return true }
    
    /// The collection view class to be used when instancing this view controller's collection view.
    /// - Precondition: it must be a subclass of *BaseCollectionView*.
    public class var collectionViewClass: UICollectionView.Type { return BaseCollectionView.self }

    // MARK: Initialization
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Collection view
        collectionView.keyboardDismissMode = .interactive
        view.addSubview(collectionView, pinningEdgesToSafeArea: [ .left, .top, .right ])
        view.pinToBottom(collectionView, useSafeAnchor: false)
        // Observers
        observers.addKeyboardObserver(handler: { [unowned self] in self.handleKeyboardFrameChanged($0) })
    }

    deinit {
        observers.removeAll()
        collectionView.bk_removeAllBlockObservers()
    }

    // MARK: Updating
    private func handleKeyboardFrameChanged(_ frame: CGRect) {
        keyboardFrameInWindow = frame
        updateContentInset()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.deselectSelectedRows(animated: animated)
        // Prevent animation on push
        collectionView.layoutIfNeeded()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateContentInset()
    }

    // MARK: Content Inset
    public func updateContentInset() {
        var bottomInset: CGFloat = 0

        let collectionViewFrameInWindow = collectionView.convert(collectionView.bounds, to: nil)
        let keyboardIntersection = collectionViewFrameInWindow.intersection(keyboardFrameInWindow)
        bottomInset = keyboardIntersection.height

        guard cachedBottomInset != bottomInset else { return }

        collectionView.contentInset.bottom = bottomInset
        collectionView.scrollIndicatorInsets.bottom = bottomInset
        cachedBottomInset = bottomInset
    }
}

