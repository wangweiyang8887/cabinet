// Copyright © 2021 evan. All rights reserved.

protocol Reuseable {}

extension UITableViewCell : Reuseable {}
extension Reuseable where Self: UITableViewCell {
    static var reuseableIdentifier: String {
        return String(describing: self)
    }
    static var nib: UINib {
        return UINib(nibName: self.reuseableIdentifier, bundle: Bundle(for: self))
    }
}

extension UITableViewHeaderFooterView : Reuseable {}
extension Reuseable where Self: UITableViewHeaderFooterView {
    static var reuseableIdentifier: String {
        return String(describing: self)
    }
    static var nib: UINib {
        return UINib(nibName: self.reuseableIdentifier, bundle: Bundle(for: self))
    }
}

extension UITableView {
    open func dequeueReusableCell<T: UITableViewCell>(_ cell: T.Type = T.self) -> T {
        guard let cell = self.dequeueReusableCell(withIdentifier: T.reuseableIdentifier) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseableIdentifier)")
        }
        return cell
    }
    
    open func dequeueReusableCell<T: UITableViewCell>(_ cell: T.Type = T.self, for indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(withIdentifier: T.reuseableIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseableIdentifier)")
        }
        return cell
    }
    
    open func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_ view: T.Type = T.self) -> T? {
        guard let view = self.dequeueReusableHeaderFooterView(withIdentifier: T.reuseableIdentifier) as? T else {
            fatalError("Could not dequeue HeaderFooterView with identifier: \(T.reuseableIdentifier)")
        }
        return view
    }

    @objc open func registerCell(withClass cellClass: AnyClass) {
        let name = String(describing: cellClass) // Must be defined in Swift because for Swift classes this is different from NSStringForClass(…)
        let nibURL = Bundle.main.url(forResource: name, withExtension: "nib")
        if nibURL != nil {
            let nib = UINib(nibName: name, bundle: nil)
            register(nib, forCellReuseIdentifier: name)
        } else {
            register(cellClass, forCellReuseIdentifier: name)
        }
    }
}
