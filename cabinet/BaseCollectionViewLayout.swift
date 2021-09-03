// Copyright © 2021 evan. All rights reserved.

import UIKit

public final class BaseCollectionViewRowLayout : UICollectionViewLayout {
    private var content = Content()
    private var actualHeightCache: [String:CGFloat] = [:]
    private var delegate: BaseCollectionViewDelegateRowLayout? { return collectionView?.delegate as? BaseCollectionViewDelegateRowLayout }
    private var hasInvalidatedFrames: Bool = true

    public var isDataSourceInvalidated: Bool { return content.sections == nil }

    public override class var layoutAttributesClass: AnyClass { return BaseCollectionViewLayoutAttributes.self }

    // MARK: Updating
    public override func prepare() {
        let (collectionView, delegate) = (self.collectionView!, self.delegate!)
        // Re-create sections & rows
        if isDataSourceInvalidated {
            let sectionCount = collectionView.numberOfSections
            content.sections = (0..<sectionCount).map { (sectionIndex: Int) -> Section in
                // Rows
                let rowCount = collectionView.numberOfItems(inSection: sectionIndex)
                let rows: [Row] = (0..<rowCount).map { (rowIndex: Int) -> Row in
                    let indexPath = IndexPath(item: rowIndex, section: sectionIndex)
                    let layoutInfo = delegate.collectionView(collectionView, layoutInfoForRowAt: indexPath)
                    let row = Row(uniqueID: layoutInfo.uniqueID, height: layoutInfo.height, margin: layoutInfo.margins, cornerRadius: layoutInfo.cornerRadius, style: layoutInfo.style)
                    if let uniqueID = layoutInfo.uniqueID {
                        if case .auto = row.height, let actualHeight = actualHeightCache[uniqueID] {
                            row.actualHeight = actualHeight // For self-sizing rows, try to get a previous actual height
                        } else {
                            actualHeightCache[uniqueID] = row.actualHeight // Store in cache
                        }
                    }
                    return row
                }
                // Layout info
                let sectionLayoutInfo = delegate.collectionView(collectionView, layoutInfoForSectionAt: sectionIndex)
                // Update separators
                for (index, row) in rows.indexed {
                    let (previousRow, nextRow) = (rows[ifPresent: index - 1], rows[ifPresent: index + 1])
                    let hasBackground = { (row: Row?) -> Bool in !(row == nil || row?.style == .backgroundless) }
                    let isFirstRowOfSection: Bool = index == 0
                    let isLastRowOfSection: Bool = index == rowCount - 1
                    let sectionHasCornerRadius: Bool = sectionLayoutInfo.cornerRadius != nil
                    row.topSeparator = {
                        if sectionHasCornerRadius && isFirstRowOfSection {
                            return false
                        } else {
                            return !hasBackground(previousRow) && hasBackground(row)
                        }
                    }()
                    row.bottomSeparator = {
                        if sectionHasCornerRadius && isLastRowOfSection {
                            return false
                        } else {
                            return (hasBackground(row) && !hasBackground(nextRow)) || (row.style == .regular && nextRow?.style == .regular)
                        }
                    }()
                }
                return Section(rows: rows, layoutInfo: sectionLayoutInfo)
            }
        }
        // Update frames
        if hasInvalidatedFrames {
            defer { hasInvalidatedFrames = false }
            // Update
            let collectionView = self.collectionView!
            var y: CGFloat = 0
            var previousRowMargin: UIEdgeInsets = .zero
            for section in content.sections {
                for (rowIndex, row) in section.rows.indexed {
                    // Our margins specify a minimum spacing, so e.g. a 32pt and 24pt margin becomes a 32pt margin, not 32pt + 24pt.
                    var margin: UIEdgeInsets = row.margin
                    var cornerRadius: CornerRadius? = row.cornerRadius
                    margin.left = max(margin.left, section.layoutInfo.margins.left)
                    margin.right = max(margin.right, section.layoutInfo.margins.right)
                    if rowIndex == 0 {
                        // First row of the section
                        margin.top = max(margin.top, section.layoutInfo.margins.top)
                        if let sectionCornerRadius = section.layoutInfo.cornerRadius {
                            cornerRadius = sectionCornerRadius
                            cornerRadius!.corners = [ .topLeft, .topRight ] // Override the corners to remove the bottom corners
                        }
                    }
                    if rowIndex == section.rows.count - 1 {
                        // Last row of the section
                        margin.bottom = max(margin.bottom, section.layoutInfo.margins.bottom)
                        if let sectionCornerRadius = section.layoutInfo.cornerRadius {
                            if cornerRadius == nil {
                                // Initialize if needed
                                cornerRadius = sectionCornerRadius
                            }
                            cornerRadius!.radius = sectionCornerRadius.radius
                            if rowIndex == 0 {
                                // If it's the last row and also the first one (i.e. the only row in the section), we must keep the top corners and add the bottom ones.
                                cornerRadius!.corners.insert([ .bottomLeft, .bottomRight ])
                            } else {
                                // Otherwise we must remove the top ones and add the bottom ones only.
                                cornerRadius!.corners = [ .bottomLeft, .bottomRight ]
                            }
                        }
                    }
                    if rowIndex != 0, rowIndex != section.rows.count - 1, section.layoutInfo.cornerRadius != nil {
                        cornerRadius = CornerRadius(radius: 0) // Ensure that middle rows of a section with cornerRadius have no cornerRadius
                    }
                    row.cornerRadius = cornerRadius
                    // Add spacing
                    let spacingWithPreviousRow = max(previousRowMargin.bottom, margin.top)
                    y += spacingWithPreviousRow
                    // Compute frame
                    row.frame = CGRect(x: margin.left, y: y, width: collectionView.bounds.width - (margin.left + margin.right), height: row.actualHeight)
                    // Prepare next
                    y += row.actualHeight
                    previousRowMargin = margin
                }
            }
            y += previousRowMargin.bottom // Last row bottom margin
            content.size = CGSize(width: collectionView.bounds.width, height: y)
        }
    }

    // MARK: Invalidation
    public override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        // Invalidate counts
        if context.invalidateDataSourceCounts {
            content.sections = nil
            hasInvalidatedFrames = true
        }
        // Invalidate frames
        if let indexPaths = context.invalidatedItemIndexPaths, !indexPaths.isEmpty {
            hasInvalidatedFrames = true
        }
        super.invalidateLayout(with: context)
    }

    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return newBounds.width != collectionView!.bounds.width
    }

    public override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds)
        context.invalidateItems(at: Array(content.indices))
        context.contentSizeAdjustment.width = (newBounds.width - collectionView!.bounds.width)
        return context
    }

    public override func shouldInvalidateLayout(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> Bool {
        guard case .auto = content[preferredAttributes.indexPath].height else { return false } // Only allow self-sizing for auto height rows
        return preferredAttributes.size.height != originalAttributes.size.height
    }

    public override func invalidationContext(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forPreferredLayoutAttributes: preferredAttributes, withOriginalAttributes: originalAttributes)
        let indexPath = originalAttributes.indexPath
        // Store new height
        let row = content[indexPath]
        row.actualHeight = preferredAttributes.size.height
        if let uniqueID = row.uniqueID { actualHeightCache[uniqueID] = row.actualHeight }
        // Invalidate layout attributes for this row and those after
        let indexPaths = Array(content.suffix(from: indexPath).indices)
        context.invalidateItems(at: indexPaths)
        // Scroll view size/offset adjustment
        let delta = preferredAttributes.size.height - originalAttributes.size.height
        context.contentSizeAdjustment.height += delta
        // If the row is above the viewing rect, move the scroll such that the visible rows don't move.
        if preferredAttributes.frame.maxY <= collectionView!.bounds.minY { context.contentOffsetAdjustment.y += delta }
        return context
    }

    // MARK: Queries
    public override func layoutAttributesForElements(in filterRect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var results: [BaseCollectionViewLayoutAttributes] = []
        for (i, row) in content.indexed {
            if row.frame.minY >= filterRect.maxY { break }
            if row.frame.maxY > filterRect.minY {
                results.append(content.layoutAttributesForRow(at: i))
            }
        }
        return results
    }

    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return content.isValidIndex(indexPath) ? content.layoutAttributesForRow(at: indexPath) : nil
    }

    public override var collectionViewContentSize: CGSize { return content.size }

    // MARK: Content
    private struct Content : Collection {
        var sections: [Section]! // nil if invalidated
        var size: CGSize = .zero

        var startIndex: IndexPath {
            let firstNonEmptySectionIndex = sections.firstIndex(where: { !$0.rows.isEmpty }) ?? sections.endIndex
            return IndexPath(item: 0, section: firstNonEmptySectionIndex)
        }

        var endIndex: IndexPath {
            return IndexPath(item: 0, section: sections.endIndex)
        }

        func index(after index: IndexPath) -> IndexPath {
            var index = index
            index.item += 1
            if index.item >= sections[index.section].rows.count { // Check for end of section
                index.item = 0
                repeat { // Advance section till we have a non-empty one
                    index.section += 1
                } while index.section < sections.count && sections[index.section].rows.isEmpty
            }
            return index
        }

        func isValidIndex(_ index: IndexPath) -> Bool {
            // Note: self[ifPresent: index] gives incorrect results, as our index (an IndexPath) could be in startIndex..<endIndex yet still be invalid.
            return sections?[ifPresent: index.section]?.rows[ifPresent: index.row] != nil
        }

        subscript(indexPath: IndexPath) -> Row {
            get {
                precondition(indexPath.count == 2)
                return sections[indexPath.section].rows[indexPath.item]
            }
            set {
                precondition(indexPath.count == 2)
                sections[indexPath.section].rows[indexPath.item] = newValue
            }
        }

        func layoutAttributesForRow(at indexPath: IndexPath) -> BaseCollectionViewLayoutAttributes {
            let row = self[indexPath]
            let layoutAttributes = BaseCollectionViewLayoutAttributes(forCellWith: indexPath)
            layoutAttributes.frame = row.frame
            layoutAttributes.topSeparator = row.topSeparator
            layoutAttributes.bottomSeparator = row.bottomSeparator
            layoutAttributes.cornerRadius = row.cornerRadius
            return layoutAttributes
        }
    }

    private struct Section {
        var rows: [Row] = []
        // Queried from data source
        var layoutInfo: BaseSection.LayoutInfo // TODO: Invalidation logic?
    }

    private class Row {
        let uniqueID: String?
        var frame: CGRect = .zero
        var actualHeight: CGFloat
        var topSeparator, bottomSeparator: Bool
        // Queried from data source
        var height: RowHeight
        var margin: UIEdgeInsets
        var cornerRadius: CornerRadius?
        var style: BaseRow.Style

        init(uniqueID: String?, height: RowHeight, margin: UIEdgeInsets, cornerRadius: CornerRadius?, style: BaseRow.Style) {
            (self.uniqueID, self.height, self.margin, self.cornerRadius, self.style, self.topSeparator, self.bottomSeparator) = (uniqueID, height, margin, cornerRadius, style, false, false)
            switch height {
            case .fixed(let heightValue): self.actualHeight = heightValue
            case .auto(let heightValue): self.actualHeight = heightValue
            }
        }
    }
}

extension BaseSection {
    public struct LayoutInfo {
        public let margins: UIEdgeInsets
        public let cornerRadius: CornerRadius?
    }
}

extension BaseRow {
    public struct LayoutInfo {
        public let uniqueID: String?
        public let height: RowHeight
        public let margins: UIEdgeInsets
        public let cornerRadius: CornerRadius?
        public let style: BaseRow.Style
    }
}

// MARK: Delegate
public protocol BaseCollectionViewDelegateRowLayout : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layoutInfoForSectionAt index: Int) -> BaseSection.LayoutInfo
    func collectionView(_ collectionView: UICollectionView, layoutInfoForRowAt indexPath: IndexPath) -> BaseRow.LayoutInfo
}

// MARK: Layout Attributes
public final class BaseCollectionViewLayoutAttributes : UICollectionViewLayoutAttributes {
    public var topSeparator: Bool = false
    public var bottomSeparator: Bool = false
    public var cornerRadius: CornerRadius?

    public override func copy(with zone: NSZone? = nil) -> Any {
        let result = super.copy(with: zone) as! BaseCollectionViewLayoutAttributes
        result.topSeparator = topSeparator
        result.bottomSeparator = bottomSeparator
        result.cornerRadius = cornerRadius
        return result
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? BaseCollectionViewLayoutAttributes,
            topSeparator == other.topSeparator,
            bottomSeparator == other.bottomSeparator,
            cornerRadius == other.cornerRadius else { return false }
        return super.isEqual(object)
    }
}

// MARK: Height
public enum RowHeight {
    case fixed(CGFloat)
    case auto(estimate: CGFloat)

    public var estimatedHeight: CGFloat {
        switch self {
        case .fixed(let height): return height
        case .auto(let estimatedHeight): return estimatedHeight
        }
    }
}

