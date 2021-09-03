// Copyright © 2021 evan. All rights reserved.

import UIKit
import MJRefresh

// MARK: - Collection View
public class BaseCollectionView : UICollectionView {
    public let collectionViewRowLayout = BaseCollectionViewRowLayout()
    fileprivate let content = Content()
    public weak var ttDelegate: BaseCollectionViewDelegate?
    public var forcedTopAlignmentIndexPath: IndexPath?
    public var sizeToContent: Bool = false { didSet { setNeedsLayout() } }
    public var shouldAutoUpdateContentInsetOnRefreshAction: Bool = true
    private var heightConstraint: NSLayoutConstraint?
    public var shouldRecognizeSimultaneously = false
    /// If set, adds a pull-to-refresh control with the given async refresh action.dash
    public var refreshHeader: ActionClosure? { didSet { handleRefreshHeaderSet() } }
    public var refreshFooter: ActionClosure? { didSet { handleRefreshFooterSet() } }
    
    public override weak var delegate: UICollectionViewDelegate? {
        didSet { precondition(delegate == nil || delegate === content, "BaseCollectionView's delegate can't be set explicitly.") }
    }

    public override weak var dataSource: UICollectionViewDataSource? {
        didSet { precondition(dataSource == nil || dataSource === content, "BaseCollectionView's dataSource can't be set explicitly.") }
    }

    public var sections: [BaseSection] {
        get { return content.sections }
        set { content.sections = newValue }
    }

    // MARK: Initialization
    public init() { super.init(frame: .zero, collectionViewLayout: collectionViewRowLayout); initialize() }
    public required init?(coder: NSCoder) { super.init(coder: coder); initialize() }

    private func initialize() {
        content.collectionView = self
        delegate = content
        dataSource = content
        alwaysBounceVertical = true
        backgroundColor = nil
        keyboardDismissMode = .interactive
    }

    // MARK: General
    public override func layoutSubviews() {
        super.layoutSubviews()
        // Size to content
        if sizeToContent {
            let height = contentSize.height
            let heightWithInsets = height + contentInset.top + contentInset.bottom
            let heightConstraint = lazy(&self.heightConstraint) { self.constrainHeight(to: heightWithInsets, priority: .medium) }
            if heightConstraint.constant != heightWithInsets { heightConstraint.constant = heightWithInsets }
        } else if let heightConstraint = heightConstraint {
            heightConstraint.isActive = false
            self.heightConstraint = nil
        }
        // Forced top alignment
        if let forcedTopAlignmentIndexPath = self.forcedTopAlignmentIndexPath {
            let activeSectionIndexes = content.activeSections.map { $0.indexInCollectionView! }
            if activeSectionIndexes.contains(forcedTopAlignmentIndexPath.section) {
                guard var sectionY = collectionViewRowLayout.layoutAttributesForItem(at: forcedTopAlignmentIndexPath)?.frame.minY else { return } // Can be missing in rare cases
                if UIDevice.isIPhoneX && forcedTopAlignmentIndexPath.section != 0 { sectionY -= 44 }
                contentOffset = CGPoint(x: 0, y: sectionY)
            } else {
                contentOffset = CGPoint(x: 0, y: collectionViewRowLayout.collectionViewContentSize.height)
            }
        }
    }

    public func invalidateRow(at indexPaths: [IndexPath]) {
        let invalidationContext = UICollectionViewLayoutInvalidationContext()
        invalidationContext.invalidateItems(at: indexPaths)
        collectionViewRowLayout.invalidateLayout(with: invalidationContext)
        if #available(iOS 13.0, *) {
            // Fix that invalidations don't work on iOS 13.
            collectionViewLayout.invalidateLayout()
        }
    }

    public func deselectSelectedRows(animated: Bool) {
        indexPathsForSelectedItems?.forEach { deselectItem(at: $0, animated: animated) }
    }

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for cell in visibleCells {
            let cell = cell as! BaseCollectionViewCell
            guard let row = cell.row, let hitTestHandler = row.hitTestHandler else { continue }
            let pointInRowCoordinates = convert(point, to: row)
            if let result = hitTestHandler(pointInRowCoordinates, event) { return result }
        }
        return super.hitTest(point, with: event)
    }

    // MARK: Content
    fileprivate class Content : NSObject, UICollectionViewDataSource, BaseCollectionViewDelegateRowLayout {
        weak var collectionView: BaseCollectionView!
        var sections: [BaseSection] = [] { didSet { handleSectionsChanged(oldValue: oldValue) } }

        // MARK: Active Sections
        private var _activeSections: [BaseSection]?
        var activeSections: [BaseSection] { // Cached computed variable
            return lazy(&_activeSections) { sections.filter { !$0.isHidden } }
        }

        func invalidateActiveSections() {
            _activeSections = nil
        }

        // MARK: Updating
        private func handleSectionsChanged(oldValue: [BaseSection]) {
            let (oldSections, newSections) = (Set(oldValue), Set(sections))
            let (removedSections, addedSections) = (oldSections.subtracting(newSections), newSections.subtracting(oldSections))
            removedSections.forEach { $0.collectionView = nil }
            addedSections.forEach { $0.collectionView = collectionView }
            invalidateActiveSections()
        }

        // MARK: Delegate & Data Source
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return activeSections.count
        }

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return activeSections[section].rowCount
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let section = activeSections[indexPath.section]
            return section.cellForRow(at: indexPath.item)
        }

        func collectionView(_ collectionView: UICollectionView, layoutInfoForSectionAt index: Int) -> BaseSection.LayoutInfo {
            return activeSections[index].layoutInfo
        }

        func collectionView(_ collectionView: UICollectionView, layoutInfoForRowAt indexPath: IndexPath) -> BaseRow.LayoutInfo {
            return activeSections[indexPath.section].layoutInfoForRow(at: indexPath.item)
        }

        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            self.collectionView.ttDelegate?.collectionView(collectionView, didSelectItemAt: indexPath)
            let section = activeSections[indexPath.section]
            section.handleDidSelectRow(at: indexPath.item)
            // Deselect, unless we pushed or full-screen presented another VC in which case we'll deselect in viewWillAppear.
            let viewController = self.collectionView.viewController ?? UIViewController.current()!
            if let navigationController = viewController.navigationController, navigationController.viewControllers.last != viewController { return }
            if let presentedViewController = viewController.presentedViewController {
                // See if the presentation style will remove current view. Contains some false negatives, but that's preferred
                let style = presentedViewController.modalPresentationStyle
                if style == .fullScreen || style == .currentContext { return }
                if viewController.traitCollection.horizontalSizeClass == .compact {
                    if style == .pageSheet || style == .formSheet { return }
                }
            }
            self.collectionView.deselectSelectedRows(animated: true)
        }

        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            collectionView.ttDelegate?.scrollViewWillBeginDragging(scrollView)
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            collectionView.visibleCells.compactMap { ($0 as? BaseCollectionViewCell)?.row }.forEach { $0.hideSwipeMenu() }
            collectionView.ttDelegate?.scrollViewDidScroll(scrollView)
        }

        func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
            collectionView.ttDelegate?.scrollViewDidEndScrollingAnimation(scrollView)
        }

        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            collectionView.ttDelegate?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            collectionView.ttDelegate?.scrollViewDidEndDecelerating(scrollView)
        }
    }

    // MARK: Refresh Control
    private func handleRefreshHeaderSet() {
        if refreshHeader != nil {
            _ = lazy(&self.mj_header) {
                let header = MJRefreshNormalHeader { [weak self] in self?.refreshHeader?() }
                header.isAutomaticallyChangeAlpha = true
                header.lastUpdatedTimeLabel?.isHidden = true
                header.setTitle("下拉刷新", for: .idle)
                header.setTitle("释放刷新", for: .pulling)
                header.setTitle("努力加载中", for: .refreshing)
                header.stateLabel?.textColor = .nonStandardColor(withRGBHex: 0xbababa)
                header.stateLabel?.font = .systemFont(ofSize: 12)
                return header
            }
        } else {
            mj_header = nil
        }
    }
    
    private func handleRefreshFooterSet() {
        if refreshFooter != nil {
            _ = lazy(&self.mj_footer) {
                let footer = MJRefreshAutoNormalFooter { [weak self] in self?.refreshFooter?() }
                footer.isAutomaticallyRefresh = false
                footer.setTitle("", for: .idle)
                footer.setTitle("释放刷新", for: .pulling)
                footer.setTitle("努力加载中", for: .refreshing)
                footer.setTitle("我们是有底线的～", for: .noMoreData)
                footer.stateLabel?.textColor = .nonStandardColor(withRGBHex: 0xbababa)
                footer.stateLabel?.font = .systemFont(ofSize: 12)
                return footer
            }
        } else {
            mj_footer = nil
        }
    }
}

public func += (lhs: BaseCollectionView, rhs: BaseSection) { lhs.sections.append(rhs) }
public func += (lhs: BaseCollectionView, rhs: [BaseSection]) { lhs.sections += rhs }

// MARK: - Section

open class BaseSection : Hashable {
    public fileprivate(set) weak var collectionView: BaseCollectionView? { didSet { if collectionView != oldValue { handleCollectionViewChanged() } } }
    /// The index of the section in the collection view, or `nil` if the section is hidden or has not been added to a collection view.
    public var indexInCollectionView: Int? { return collectionView?.content.activeSections.firstIndex(of: self) }
    public var contents: [SectionContentItem] = [] { didSet { handleContentsSet(oldValue: oldValue) } }
    public var margin: UIEdgeInsets
    public var cornerRadius: CornerRadius?
    public var isHidden: Bool = false { didSet { if isHidden != oldValue { handleIsHiddenChanged() } } }

    // MARK: Initialization
    public init(_ contents: [SectionContentItem] = [], margins: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0), cornerRadius: CornerRadius? = nil) {
        (self.contents, self.margin, self.cornerRadius) = (contents, margins, cornerRadius)
        handleContentsSet(oldValue: []) // Property observers are not called within initializers
    }

    // MARK: Updating
    private func handleIsHiddenChanged() {
        collectionView?.content.invalidateActiveSections()
        collectionView?.reloadData()
    }

    private func handleCollectionViewChanged() {
        contents.forEach { $0.registerCells() }
    }

    private func handleContentsSet(oldValue: [SectionContentItem]) {
        let removedItems = oldValue.filter { item in !contents.contains { $0 === item } }
        let addedItems = contents.filter { item in !oldValue.contains { $0 === item } }
        removedItems.forEach { $0.section = nil }
        for addedItem in addedItems {
            if let oldSection = addedItem.section {
                oldSection.contents = oldSection.contents.filter { $0 !== addedItem }
            }
            addedItem.section = self
        }
        // Only call out after all other changes are done
        addedItems.forEach { $0.registerCells() }
    }

    // MARK: General
    public var rowCount: Int { return contents.lazy.map { !$0.isHidden ? $0.rowCount : 0 }.reduce(0, +) }

    public func cellForRow(at index: Int) -> UICollectionViewCell {
        let (item, indexInItem) = mapIndex(index)!
        return item.cellForRow(at: indexInItem)
    }

    public var layoutInfo: LayoutInfo {
        return LayoutInfo(margins: margin, cornerRadius: cornerRadius)
    }

    public func layoutInfoForRow(at index: Int) -> BaseRow.LayoutInfo {
        let (item, indexInItem) = mapIndex(index)!
        return item.layoutInfoForRow(at: indexInItem)
    }

    public func handleDidSelectRow(at index: Int) {
        let (item, indexInItem) = mapIndex(index)!
        item.handleDidSelectRow(at: indexInItem)
    }

    // MARK: Index Conversion
    private func mapIndex(_ index: Int) -> (item: SectionContentItem, index: Int)? {
        var indexInItem = index
        for item in contents {
            if item.isHidden { continue }
            let rowCount = item.rowCount
            if indexInItem < rowCount { return (item, indexInItem) }
            indexInItem -= rowCount
        }
        return nil
    }

    public func indexPathForRow(at indexInItem: Int, in item: SectionContentItem) -> IndexPath? {
        guard let sectionIndex = indexInCollectionView else { return nil }
        var offset = 0
        for currentItem in contents {
            if currentItem.isHidden { continue }
            if let index = currentItem.indexForRow(at: indexInItem, in: item) {
                return IndexPath(item: offset + index, section: sectionIndex)
            }
            offset += currentItem.rowCount
        }
        return nil
    }

    public static func == (lhs: BaseSection, rhs: BaseSection) -> Bool { return lhs === rhs }
    public func hash(into hasher: inout Hasher) { return ObjectIdentifier(self).hash(into: &hasher) }
}

public protocol BaseCollectionViewDelegate : AnyObject {
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
}

extension BaseCollectionViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {}
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {}
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {}
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {}
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {}
}

// MARK: - Section Content Item

public protocol SectionContentItem : AnyObject {
    var section: BaseSection? { get set } // TODO: Implement some kind of guard again sets, ideally set would be private
    var isHidden: Bool { get }

    // BaseCollectionView internal use only
    func registerCells()
    var rowCount: Int { get }
    func cellForRow(at index: Int) -> UICollectionViewCell
    func layoutInfoForRow(at index: Int) -> BaseRow.LayoutInfo
    func handleDidSelectRow(at index: Int)
    // Overriden to support content items containing nested BaseRows (e.g. ItemRows' emptyCell)
    func indexForRow(at indexInItem: Int, in item: SectionContentItem) -> Int?
}

extension SectionContentItem {
    public var collectionView: BaseCollectionView? { return section?.collectionView }
}

extension BaseCollectionView {
    enum Kind { case header, footer }
    
    func startRefresh(_ kind: Kind = .header) {
        switch kind {
        case .header: mj_header?.beginRefreshing()
        case .footer: mj_footer?.beginRefreshing()
        }
    }
    
    func endRefresh() {
        mj_header?.endRefreshing()
        mj_footer?.endRefreshing()
    }
    
    func endRefreshingWithNoMoreData() {
        mj_header?.endRefreshing()
        mj_footer?.endRefreshingWithNoMoreData()
    }
}
    
extension BaseCollectionView : UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return shouldRecognizeSimultaneously
    }
}

