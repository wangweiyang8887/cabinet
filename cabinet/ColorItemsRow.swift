// Copyright © 2021 evan. All rights reserved.

import FMPhotoPicker

class ColorItemsRow : BaseRow {
    enum Kind { case normal, gradient }
    
    override class var margins: UIEdgeInsets { return .zero }
    override class var height: RowHeight { return .fixed(60) }
    
    var gradientHandler: ValueChangedHandler<TTGradient>?
    var colorHandler: ValueChangedHandler<UIColor>?
    var imageHandler: ValueChangedHandler<UIImage>?
    var kind: Kind = .normal
    
    override func initialize() {
        super.initialize()
        backgroundColor = .clear
        contentView.addSubview(uiCollectionView, pinningEdges: .all)
    }
    
    private lazy var uiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(uniform: 60)
        layout.minimumLineSpacing = 16
        let result = UICollectionView(frame: .zero, collectionViewLayout: layout)
        result.backgroundColor = .clear
        result.delegate = self
        result.dataSource = self
        result.showsHorizontalScrollIndicator = false
        result.contentInset.left = 16
        result.registerCell(withClass: Cell.self)
        result.registerCell(withClass: PhotoCell.self)
        return result
    }()
}

extension ColorItemsRow : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return kind == .normal ? UIColor.allCases.count : (TTGradient.allCases.count + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if kind == .normal {
            let cell = collectionView.dequeueReusableCell(with: Cell.self, for: indexPath)
            cell.gradient = [ UIColor.allCases[indexPath.row] ]
            return cell
        } else {
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(with: PhotoCell.self, for: indexPath)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(with: Cell.self, for: indexPath)
                cell.gradient = TTGradient.allCases[indexPath.row - 1]
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if kind == .normal {
            colorHandler?(UIColor.allCases[indexPath.row])
        } else {
            if indexPath.row == 0 {
                AuthorizationView.showAlert(with: .photoLibrary) { [unowned self] in
                    let picker = FMPhotoPickerViewController(config: FMPhotoPickerConfig.defaultConfig)
                    picker.delegate = self
                    UIViewController.current().present(picker, animated: true)
                }
            } else {
                gradientHandler?(TTGradient.allCases[indexPath.row - 1])
            }
        }
    }
}

extension ColorItemsRow : FMPhotoPickerViewControllerDelegate {
    func fmPhotoPickerController(_ picker: FMPhotoPickerViewController, didFinishPickingPhotoWith photos: [UIImage]) {
        if let image = photos.first?.tinted(with: UIColor.black.withAlphaComponent(0.15)) { imageHandler?(image) }
        UIViewController.current().dismissSelf()
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
            contentView.cornerRadius = 30
            contentView.borderWidth = 1
            contentView.borderColor = .cabinetSeparator
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private lazy var gradientView: TTGradientView = {
            let result = TTGradientView(gradient: gradient, direction: .topLeftToBottomRight)
            return result
        }()
    }
    
    final class PhotoCell : UICollectionViewCell {
        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.addSubview(titleLabel, pinningEdges: .all)
            contentView.addSubview(imageView, pinningEdges: .all)
            contentView.cornerRadius = 30
            contentView.borderWidth = 1
            contentView.borderColor = .cabinetSeparator
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private lazy var titleLabel = UILabel(text: "相册", font: .systemFont(ofSize: 17, weight: .medium), color: .cabinetBlack, alignment: .center, lines: 0)
        
        private lazy var imageView: UIImageView = {
            let result = UIImageView()
            result.contentMode = .scaleAspectFill
            result.backgroundColor = .clear
            return result
        }()
        
        var image: UIImage? {
            get { return imageView.image }
            set { imageView.image = newValue }
        }
    }
}
