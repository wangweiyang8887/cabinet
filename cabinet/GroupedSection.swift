// Copyright © 2021 evan. All rights reserved.

/// A section that implements a grouped layout according to the design guidelines, by default.
open class GroupedSection : BaseSection {
    /// Whether the rows contained in this section will display separators between them.
    public var showsSeparators: Bool = true { didSet { handleShowsSeparatorsChanged() } }

    public init(_ contents: [SectionContentItem] = [], margins: UIEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16), cornerRadius: CornerRadius = CornerRadius(radius: TTCornerRadius.large)) {
        super.init(contents, margins: margins, cornerRadius: cornerRadius)
        handleShowsSeparatorsChanged()
    }

    private func handleShowsSeparatorsChanged() {
        contents.forEach {
            guard let row = $0 as? BaseRow else { return }
            row.topSeparatorMode = showsSeparators ? .auto : .hide
            row.bottomSeparatorMode = showsSeparators ? .auto : .hide
        }
    }
}

class SeparatorlessGroupedSection : GroupedSection {
    override init(_ contents: [SectionContentItem] = [], margins: UIEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16), cornerRadius: CornerRadius = CornerRadius(radius: TTCornerRadius.default)) {
        super.init(contents, margins: margins, cornerRadius: cornerRadius)
        showsSeparators = false
    }
}
