// Copyright © 2021 evan. All rights reserved.

import FMPhotoPicker
import WidgetKit

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
        let gradientView = TTGradientView(gradient: [ .nonStandardColor(withRGBHex: 0x1770f3).withAlphaComponent(0.7), .cabinetTuna.withAlphaComponent(0.7) ])
        gradientView.cornerRadius = 16
        contentView.addSubview(gradientView, pinningEdges: .all)
        contentView.sendSubviewToBack(gradientView)
    }
    
    override func handleDidSelect() {
        super.handleDidSelect()
        AuthorizationView.showAlert(with: .photoLibrary) { [unowned self] in
            var config = FMPhotoPickerConfig()
            config.maxImage = 1
            config.strings["picker_button_cancel"] = "取消"
            config.strings["picker_button_select_done"] = "确定"
            config.strings["picker_warning_over_image_select_format"] = "只能选择 %d 张图片"
            config.strings["present_button_back"] = "返回"
            config.strings["present_button_edit_image"] = "编辑"
            config.strings["editor_button_cancel"] = "取消"
            config.strings["editor_button_done"] = "完成"
            config.strings["editor_menu_filter"] = "滤镜"
            config.strings["editor_menu_crop"] = "裁剪"
            config.strings["present_title_photo_created_date_format"] = "yyyy.MM.dd"
            let picker = FMPhotoPickerViewController(config: config)
            picker.delegate = self
            UIViewController.current().present(picker, animated: true)
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
    
    private lazy var titleLabel: UILabel = UILabel(text: "选择图片", font: .systemFont(ofSize: 24, weight: .medium), color: .white, alignment: .center, lines: 1)
}

extension ImageRow : FMPhotoPickerViewControllerDelegate {
    func fmPhotoPickerController(_ picker: FMPhotoPickerViewController, didFinishPickingPhotoWith photos: [UIImage]) {
        imageView.image = photos.first
        UserDefaults.shared[.userImage] = photos.first?.jpegData(compressionQuality: 0.7)
        titleLabel.isHidden = true
        UIViewController.current().dismissSelf()
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
