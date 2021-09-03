// Copyright © 2021 evan. All rights reserved.

import UIKit

public final class ItemRows<Item> : SectionContentItem {
    public weak var section: BaseSection? { didSet { handleSectionChanged() } }
    // Item Row
    public var itemRowClass: BaseRow.Type { didSet { if itemRowClass != oldValue { registerCells() } } }
    public var itemRowConfiguration: ItemRowConfiguration?
    public var selectionHandler: ItemSelectionHandler?
    public var isHidden: Bool = false
    // Items
    private var _items: [Item] = []
    public var items: [Item] { get { return _items } set { _items = newValue; handleItemsSet() } }
    public var maxItemRows: Int?
    public var itemsChangedHandler: ItemsChangedHandler? { didSet { handleItemsChangedHandlerChanged() } }
    // Empty state
    public var emptyRow: BaseRow? { didSet { handleEmptyRowSet() } }
    // Other
    public var reloadCollectionViewAutomatically = true

    public typealias ItemRowConfiguration = (BaseRow, Item) -> Void
    public typealias ItemSelectionHandler = (Item) -> Void
    public typealias ItemsChangedHandler = ([Item]) -> Void

    // MARK: Intialization
    public init(itemRowClass: BaseRow.Type) {
        self.itemRowClass = itemRowClass
    }

    // MARK: Updating
    private func handleSectionChanged() {
        emptyRow?.section = section
    }

    private func handleEmptyRowSet() {
        emptyRow?.section = section
        emptyRow?.registerCells()
    }

    // MARK: Content Item
    public var rowCount: Int {
        if let emptyRow = emptyRowIfShown { return emptyRow.rowCount }
        // Item rows
        if let maxItemsRows = maxItemRows {
            return items.count.constrained(toMax: maxItemsRows)
        } else {
            return items.count
        }
    }

    public func registerCells() {
        collectionView?.register(BaseCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(itemRowClass))
        emptyRow?.registerCells()
    }

    public func cellForRow(at index: Int) -> UICollectionViewCell {
        if let emptyRow = emptyRowIfShown { return emptyRow.cellForRow(at: index) }
        // Item rows
        assert(0..<rowCount ~= index)
        // Dequeue cell
        let indexPath = indexPathForItem(at: index)!
        let cell = collectionView!.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(itemRowClass), for: indexPath) as! BaseCollectionViewCell
        // Configure cell
        let row = lazy(&cell.row) { itemRowClass.init() }
        row.section = section
        assert(row.isKind(of: itemRowClass))
        let item = items[index]
        if let configuration = itemRowConfiguration {
            configuration(row, item)
        } else {
            row.item = item
        }
        return cell
    }

    public func layoutInfoForRow(at index: Int) -> BaseRow.LayoutInfo {
        if let emptyRow = emptyRowIfShown { return emptyRow.layoutInfoForRow(at: 0) }
        assert(0..<rowCount ~= index)
        // Unique ID
        let id = UInt(bitPattern: ObjectIdentifier(self))
        let item = items[index]
        let itemID = String(UInt(bitPattern: ObjectIdentifier(item as AnyObject)))
        let uniqueID = "\(id)-\(itemID)"
        // Height
        let height = itemRowClass.computeHeight(forItem: item)
        // Return
        return BaseRow.LayoutInfo(uniqueID: uniqueID, height: height, margins: itemRowClass.margins, cornerRadius: nil, style: itemRowClass.style)
    }

    public func handleDidSelectRow(at index: Int) {
        if let emptyRow = emptyRowIfShown { emptyRow.handleDidSelectRow(at: index); return }
        // Item rows
        assert(0..<rowCount ~= index)
        if let selectionHandler = selectionHandler {
            selectionHandler(items[index])
        } else {
            let cell = collectionView!.cellForItem(at: indexPathForItem(at: index)!) as! BaseCollectionViewCell
            cell.row!.handleDidSelectRow(at: 0)
        }
    }

    public func indexForRow(at indexInItem: Int, in item: SectionContentItem) -> Int? {
        if let emptyRow = emptyRowIfShown { return emptyRow.indexForRow(at: indexInItem, in: emptyRow) }
        // Item rows
        if item === self, !isHidden, 0..<rowCount ~= indexInItem { return indexInItem }
        return nil
    }

    // MARK: Item Source
    private func handleItemsSet() {
        handleItemsChanged()
    }

    private func handleItemsChanged() {
        itemsChangedHandler?(items)
        guard reloadCollectionViewAutomatically else { return }
        collectionView?.reloadData() // TODO: Switch to partial reloading when available
    }

    private func handleItemsChangedHandlerChanged() {
        itemsChangedHandler?(items)
    }

    // MARK: Convenience
    private var emptyRowIfShown: BaseRow? { return items.isEmpty ? emptyRow : nil }

    /// Non-nil if the row is currently in the collection view.
    public func indexPathForItem(at index: Int) -> IndexPath? {
        precondition(items.indices ~= index)
        return section?.indexPathForRow(at: index, in: self)
    }

    /// Returns the `BaseRow` for the item at the given index or `nil` if the row is not visible.
    public func rowForItem(at index: Int) -> BaseRow? {
        guard let indexPath = indexPathForItem(at: index),
            let cell = collectionView?.cellForItem(at: indexPath) as! BaseCollectionViewCell? else { return nil }
        return cell.row
    }

    /// Returns the rows that are currently visible.
    public var visibleRows: [BaseRow] {
        return items.indices.compactMap { rowForItem(at: $0) }
    }
}
