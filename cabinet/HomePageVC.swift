// Copyright © 2021 evan. All rights reserved.

import UIKit

class HomePageVC : BaseViewController {
    var items: [String] = [ "A","B","C","D","E","F","G","H","I","J" ]
    var isEnded: Bool = true

    var currentMoveCell: MyCell?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(uiCollectionView, pinningEdges: .all)
    }
    
    private lazy var uiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 32, height: 70)
        layout.scrollDirection = .vertical
        let result = UICollectionView(frame: .zero, collectionViewLayout: layout)
        result.dataSource = self
        result.delegate = self
        result.registerCell(withClass: MyCell.self)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture))
        result.addGestureRecognizer(longPress)
        return result
    }()
    
    @objc func handleLongGesture(longPress: UILongPressGestureRecognizer) {
        switch longPress.state {
        case .began:
            isEnded = false
            if let selectedIndexPath = uiCollectionView.indexPathForItem(at: longPress.location(in: uiCollectionView)) {
                currentMoveCell = uiCollectionView.cellForItem(at: selectedIndexPath) as? MyCell
                currentMoveCell?.layer.borderWidth = 5.0
                currentMoveCell?.layer.borderColor = UIColor.red.cgColor
                uiCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            }
        case .changed:
            isEnded = false
            uiCollectionView.updateInteractiveMovementTargetPosition(longPress.location(in: uiCollectionView))
        case .ended:
            isEnded = true
            uiCollectionView.performBatchUpdates {
                currentMoveCell?.layer.borderWidth = 0.0
                uiCollectionView.endInteractiveMovement()
            } completion: { _ in
                self.currentMoveCell = nil
            }


        case .failed, .possible, .cancelled:
            isEnded = true
            uiCollectionView.cancelInteractiveMovement()
        @unknown default:break
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }
}

extension HomePageVC : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = currentMoveCell, isEnded {
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(with: MyCell.self, for: indexPath)
            cell.title = items[indexPath.row]
            cell.backgroundColor = .orange
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let selectModel = items[sourceIndexPath.item]
        items.remove(at: sourceIndexPath.item)
        items.insert(selectModel, at: destinationIndexPath.item)
    }
}

final class MyCell : UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel, pinningEdges: .all)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = .yellow
        result.font = .systemFont(ofSize: 27, weight: .medium)
        result.textAlignment = .center
        return result
    }()
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
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
