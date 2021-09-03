// Copyright © 2021 evan. All rights reserved.

import UIKit

public class Global : NSObject {
    @objc public static func unqualifiedClassName(_ type: AnyClass) -> String {
        return String(describing: type) // Not the same as NSStringFromClass(…), which returns the fully-qualified name.
    }
}

extension UICollectionView {
    /// Register a cell for a given class type, taking into consideration nibs and xibs.
    @objc public func registerCell(withClass cellClass: AnyClass) {
        let name = String(describing: cellClass) // Must be defined in Swift because for Swift classes this is different from NSStringForClass(…)
        guard Bundle.main.url(forResource: name, withExtension: "nib") != nil else {
            register(cellClass, forCellWithReuseIdentifier: name)
            return
        }
        let nib = UINib(nibName: name, bundle: nil)
        register(nib, forCellWithReuseIdentifier: name)
    }
    
    /// Returns a reusable collection view cell object for the specified reuse identifier and adds it to the table.
    /// - Note: `withIdentifier` must be equal to the Cell Class.
    func dequeueReusableCell<T : UICollectionViewCell>(with cell: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: String(describing: cell.self), for: indexPath) as! T
    }
}
