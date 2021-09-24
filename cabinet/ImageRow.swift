// Copyright © 2021 evan. All rights reserved.

final class ImageRow : BaseRow {
    override class var height: RowHeight { return .fixed(168) }
    override class var margins: UIEdgeInsets { return UIEdgeInsets(uniform: 16) }
    
    override func initialize() {
        super.initialize()
        backgroundColor = .clear
        contentView.addSubview(imageView, pinningEdges: .all)
        contentView.addSubview(titleLabel, pinningEdges: .all)
        contentView.cornerRadius = 16
        contentView.addShadow(radius: 16, yOffset: -1)
        let gradientView = TTGradientView(gradient: [ UIColor.red.withAlphaComponent(0.4), UIColor.blue.withAlphaComponent(0.4) ])
        gradientView.cornerRadius = 16
        contentView.addSubview(gradientView, pinningEdges: .all)
        contentView.sendSubviewToBack(gradientView)
    }
    
    override func handleDidSelect() {
        super.handleDidSelect()
        AuthorizationView.showAlert(with: .photoLibrary) { [unowned self] in
            let picker = MediaPicker(mediaType: .image, preferredCameraSource: .front)
            picker.didPickImages = { [unowned self] images, _ in
                guard let image = images.first else { return }
                self.imageView.image = image
                UserDefaults.shared[.userImage] = image.jpegData(compressionQuality: 0.7)
                self.titleLabel.isHidden = true
            }
            UIViewController.current()?.show(mediaPicker: picker, options: [ .camera, .photoLibrary ])
        }
    }
    
    private lazy var imageView: UIImageView = {
        let result = UIImageView()
        result.contentMode = .scaleAspectFill
        result.clipsToBounds = true
        result.cornerRadius = 16
        if let data = UserDefaults.shared[.userImage] {
            result.image = UIImage(data: data)
            self.titleLabel.isHidden = true
        }
        return result
    }()
    
    private lazy var titleLabel: UILabel = UILabel(text: "选择图片", font: .systemFont(ofSize: 17, weight: .medium), color: .white, alignment: .center, lines: 1)
}
