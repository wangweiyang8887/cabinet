// Copyright © 2021 evan. All rights reserved.

final class MediaPicker : MediaPicking {
    var didPickMediaURLs: MediaPickingURLsBlock?
    var didPickImages: MediaPickingImagesBlock?
    var didPickDocumentData: MediaPickingDocumentDataBlock?
    var automaticImageCompression = true
    fileprivate var UTIs: [String] {
        var result: [String] = []
        if mediaType.contains(.image) { result += DocumentExtension.jpeg.UTI; result += DocumentExtension.png.UTI }
        if mediaType.contains(.pdf) { result += DocumentExtension.pdf.UTI }
        if mediaType.contains(.document) { result += DocumentExtension.doc.UTI; result += DocumentExtension.docx.UTI }
        return result
    }

    fileprivate var mediaType: MediaType
    fileprivate var cameraSource: CameraSource
    var allowsCropping = false
    
    var closoure: SelectionHandler<(a:String, b:String)>?

    // MARK: Nested Types
    struct MediaType : OptionSet {
        let rawValue: Int
        static var image = MediaType(rawValue: 1 << 0)
        static var pdf = MediaType(rawValue: 1 << 1)
        static var document = MediaType(rawValue: 1 << 2)
        static var all: MediaType = [ .image, .pdf, .document ]
    }

    struct Source : OptionSet {
        let rawValue: Int
        static var camera = Source(rawValue: 1 << 0)
        static var photoLibrary = Source(rawValue: 1 << 1)
        static var googleDrive = Source(rawValue: 1 << 2)
        static var dropbox = Source(rawValue: 1 << 3)
        static var iCloudDrive = Source(rawValue: 1 << 4)
        static var all: Source = [ .camera, .photoLibrary, .googleDrive, .dropbox, .iCloudDrive ]
    }

    init(mediaType: MediaType, preferredCameraSource: CameraSource = .rear) {
        self.mediaType = mediaType
        cameraSource = preferredCameraSource
    }

    // MARK: Helper
    // Checks if the array of data exceeds the file size limit. Returns an error if so, otherwise nil.
    func handleFileSizeExcess() {}

    func handleInvalidFile() {}

    func forward(error: Error) {
        didPickMediaURLs?([], [ error])
        didPickImages?([], [ error ])
        didPickDocumentData?([], [ error ])
    }
}

extension UIViewController {
    func show(mediaPicker: MediaPicker, options: MediaPicker.Source = .all) {
        let camera = UIAlertAction(title: NSLocalizedString("拍照", comment: ""), style: .default) { [unowned self] _ in
            var picker: MediaPicking = {
                if mediaPicker.allowsCropping {
                    return CroppableImagePickerController(source: .camera, preferredCameraSource: mediaPicker.cameraSource == .rear ? .rear : .front, automaticImageCompression: mediaPicker.automaticImageCompression)
                } else {
                    return ImagePickerController(source: .camera, preferredCameraSource: mediaPicker.cameraSource == .rear ? .rear : .front, automaticImageCompression: mediaPicker.automaticImageCompression)
                }
            }()
            picker.didPickImages = mediaPicker.didPickImages
            picker.didPickMediaURLs = mediaPicker.didPickMediaURLs
            picker.didPickDocumentData = mediaPicker.didPickDocumentData
            self.show(imagePicker: picker)
        }
        let photoLibraryTitle = NSLocalizedString("从手机相册选择", comment: "")
        let photoLibrary = UIAlertAction(title: photoLibraryTitle, style: .default) { [unowned self] _ in
            var picker: MediaPicking = ImagePickerController(source: .photoLibrary, preferredCameraSource: mediaPicker.cameraSource == .rear ? .rear : .front)
            picker.didPickImages = mediaPicker.didPickImages
            picker.didPickMediaURLs = mediaPicker.didPickMediaURLs
            picker.didPickDocumentData = mediaPicker.didPickDocumentData
            self.show(imagePicker: picker)
        }

        let cancel = UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .cancel)
        let alertSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if options.contains(.camera) { alertSheet.addAction(camera) }
        if options.contains(.photoLibrary) { alertSheet.addAction(photoLibrary) }
        alertSheet.addAction(cancel)
        alertSheet.present(on: self)
    }
}

protocol MediaPicking {
    // TODO: Convert these to tuples so the objects are reliably matchable, when there're only Swift files using them.
    typealias MediaPickingURLsBlock = ([URL], [Error]) -> Void
    typealias MediaPickingImagesBlock = ([UIImage], [Error]) -> Void
    typealias MediaPickingDocumentDataBlock = ([DocumentData], [Error]) -> Void
    /// Use this block to send URLs straight to the servers
    var didPickMediaURLs: MediaPickingURLsBlock? { get set }
    /// Use this block call to display the images picked
    var didPickImages: MediaPickingImagesBlock? { get set }
    /// Use this block to parse the data alongside the mime type to be sent to the servers.
    var didPickDocumentData: MediaPickingDocumentDataBlock? { get set }
}

// Implementing this extension as fileprivate avoids namespace pollution.
extension UIViewController {
    fileprivate func show(imagePicker: MediaPicking) {
        switch imagePicker {
        case let picker as ImagePickerController: show(imagePicker: picker)
        case let picker as UIViewController: show(imagePicker: picker)
        default: 🔥
        }
    }

    private func show(imagePicker: ImagePickerController) {
        AuthorizationView.showAlert(with: (imagePicker.source == .camera) ? .camera : .photoLibrary) { [unowned self] in imagePicker.show(from: self) }
    }

    private func show(imagePicker: UIViewController) {
        AuthorizationView.showAlert(with: .photoLibrary) { [unowned self] in
            let navigationController = BaseNavigationController(rootViewController: imagePicker)
            navigationController.navigationBar.isHidden = true
            self.present(navigationController, animated: true, completion: nil)
        }
    }
}
