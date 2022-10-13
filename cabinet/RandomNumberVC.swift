// Copyright © 2022 evan. All rights reserved.

import Foundation

class RandomNumberVC : BaseViewController, SheetPresentable {
    private var maximumValue: Int = 100
    private var minimumValue: Int = 0
    private var values: [Int] { return (minimumValue...maximumValue).map { $0 } }
    private var numbers: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "\(minimumValue) ~ \(maximumValue)"
        view.addSubview(collectionView, pinningEdges: .all, withInsets: UIEdgeInsets(horizontal: 16, vertical: 100))
        view.addSubview(numberLabel, constrainedToCenterWithOffset: .zero)
        view.addSubview(editButton, pinningEdges: [ .right, .bottom ], withInsets: UIEdgeInsets(horizontal: 16, vertical: 48))
        navigationItem.leftBarButtonItem = UIBarButtonItem.textButtonItem(with: "clean", action: { [unowned self] in
            self.numbers = []
            self.collectionView.reloadData()
        })
        navigationItem.rightBarButtonItem = UIBarButtonItem.textButtonItem(with: "start", action: { [unowned self] in
            self.fire()
        })
    }
    
    private lazy var numberLabel: CountingLabel = {
        let result = CountingLabel()
        result.text = "\(minimumValue)"
        result.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        result.textAlignment = .center
        result.constrainSize(to: CGSize(width: UIScreen.main.bounds.width - 32, height: 70))
        return result
    }()
    
    private lazy var editButton: TTButton = {
        let result = TTButton()
        result.setImage(UIImage(named: "32-edit"), for: .normal)
        result.constrainSize(to: CGSize(uniform: 32))
        result.addTapHandler { [unowned self] in
            RandomEditSheetVC.show(with: self) { range in
                self.minimumValue = range.lowerBound
                self.maximumValue = range.upperBound
                self.title = "\(minimumValue) ~ \(maximumValue)"
                self.numbers = []
                self.collectionView.reloadData()
            }
        }
        return result
    }()
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = CompactFlowLayout(minimumInteritemSpacing: 8, minimumLineSpacing: 8, sectionInset: .zero)
        let result = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        result.backgroundColor = .clear
        result.delegate = self
        result.dataSource = self
        result.registerCell(withClass: Cell.self)
        return result
    }()
    
    private func fire() {
        numberLabel.reset()
        numberLabel.count(from: 0, to: maximumValue, animated: true) { [unowned self] in
            var array = self.values
            array.removeAll(where: { numbers.contains($0) })
            guard !array.isEmpty else { return }
            self.numberLabel.text = String(format: "%d", randomValue(array))
            self.collectionView.reloadData()
        }
    }
    
    private func randomValue(_ items: [Int]) -> Int {
        let lock = NSLock()
        lock.lock()
        let value = items[Int.random(in: 0..<items.count)]
        numbers.insert(value, at: 0)
        if numbers.count > 10 { numbers = numbers.dropLast() }
        lock.unlock()
        return value
    }
}

extension RandomNumberVC : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numbers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: Cell.self, for: indexPath)
        cell.title = "\(numbers[indexPath.row])"
        return cell
    }
}

extension RandomNumberVC {
    class Cell : UICollectionViewCell {
        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.backgroundColor = .cabinetDarkestGray
            contentView.addSubview(titleLabel, pinningEdges: .all, withInsets: UIEdgeInsets(uniform: 4))
            contentView.cornerRadius = 4
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private lazy var titleLabel: UILabel = {
            let result = UILabel()
            result.textColor = .cabinetWhite
            result.textAlignment = .center
            return result
        }()
        
        var title: String? {
            get { return titleLabel.text }
            set { titleLabel.text = newValue }
        }
    }
}

private class CompactFlowLayout : UICollectionViewFlowLayout {
    private let maxWidth: CGFloat
    
    init(minimumInteritemSpacing: CGFloat = 0, minimumLineSpacing: CGFloat = 0, sectionInset: UIEdgeInsets = .zero, maxWidth: CGFloat = UIScreen.main.bounds.width - 32) {
        self.maxWidth = maxWidth
        super.init()
        estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        self.minimumInteritemSpacing = minimumInteritemSpacing
        self.minimumLineSpacing = minimumLineSpacing
        self.sectionInset = sectionInset
    }
    
    required init?(coder aDecoder: NSCoder) { 🔥 }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let layoutAttributes = super.layoutAttributesForElements(in: rect), scrollDirection == .vertical else { return nil }
        let cellAttributes = layoutAttributes.filter { $0.representedElementCategory == .cell }
        Dictionary(grouping: cellAttributes) { ($0.center.y / 10).rounded(.up) * 10 }.forEach { _, attributes in
            var leftInset = sectionInset.left
            attributes.forEach {
                $0.frame = CGRect(origin: $0.frame.origin, size: CGSize(width: $0.frame.width.constrained(toMax: maxWidth), height: $0.frame.height))
                $0.frame.origin.x = leftInset
                leftInset = $0.frame.maxX + minimumInteritemSpacing
            }
        }
        return layoutAttributes
    }
}
