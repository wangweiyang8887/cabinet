// Copyright © 2021 evan. All rights reserved.

class ColorItemsRow : BaseRow {
    
    override class var margins: UIEdgeInsets { return UIEdgeInsets(horizontal: 0, vertical: 16) }
    override class var height: RowHeight { return .fixed(80) }
    
    var gradientHandler: ValueChangedHandler<TTGradient>?
    
    override func initialize() {
        super.initialize()
        backgroundColor = .clear
        contentView.addSubview(uiCollectionView, pinningEdges: .all)
    }
    
    private lazy var uiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(uniform: 80)
        layout.minimumLineSpacing = 16
        let result = UICollectionView(frame: .zero, collectionViewLayout: layout)
        result.backgroundColor = .clear
        result.delegate = self
        result.dataSource = self
        result.showsHorizontalScrollIndicator = false
        result.contentInset.left = 16
        result.registerCell(withClass: Cell.self)
        return result
    }()
}

extension ColorItemsRow : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TTGradient.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: Cell.self, for: indexPath)
        cell.gradient = TTGradient.allCases[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        gradientHandler?(TTGradient.allCases[indexPath.row])
    }
}

extension ColorItemsRow {
    final class Cell : UICollectionViewCell {
        var gradient: TTGradient = .curiousBlueToBrinkPink {
            didSet {
                gradientView.gradient = gradient
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.addSubview(gradientView, pinningEdges: .all)
            gradientView.cornerRadius = 16
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private lazy var gradientView: TTGradientView = {
            let result = TTGradientView(gradient: gradient, direction: .topLeftToBottomRight)
            return result
        }()
    }
}
