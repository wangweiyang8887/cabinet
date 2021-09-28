// Copyright © 2021 evan. All rights reserved.

@objc
enum CameraSource : Int { case front, rear }

import Photos
import CoreServices

/// A UIImagePickerController wrapper. NOTE: This class isn't a subclass of UIImagePickerController because it shouldn't be subclasses.
class TTImagePickerController : NSObject, MediaPicking, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var didPickMediaURLs: MediaPickingURLsBlock?
    /// Returns the edited image by default. If it's nil, it returns the original image.
    var didPickImages: MediaPickingImagesBlock?
    var didPickDocumentData: MediaPickingDocumentDataBlock?
    var source: UIImagePickerController.SourceType
    var camera: UIImagePickerController.CameraDevice
    private let automaticImageCompression: Bool
    class var isCroppable: Bool { return false }
    private var uiImagePickerController: UIImagePickerController {
        let result = UIImagePickerController()
        result.allowsEditing = Self.isCroppable
        result.sourceType = source
        if source == .camera { result.cameraDevice = camera } // This line can't be performed if sourceType != .camera
        result.mediaTypes = [ kUTTypeImage ] as [String]
        result.videoQuality = .typeIFrame1280x720
        result.videoMaximumDuration = 59
        result.delegate = self
        result.pgImagePicker = self
        return result
    }

    init(source: UIImagePickerController.SourceType, preferredCameraSource: UIImagePickerController.CameraDevice = .rear, automaticImageCompression: Bool = true) {
        (self.source, camera, self.automaticImageCompression) = (source, preferredCameraSource, automaticImageCompression)
        super.init()
    }

    // MARK: Presentation
    func show(from viewController: UIViewController) {
        viewController.present(uiImagePickerController, animated: true, completion: nil)
    }

    // MARK: UIImagePickerController Delegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey:Any]) {
        guard let mediaType = info[.mediaType] else { return }
        guard let image = ((info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage))?.fixOrientation() else {
            picker.presentingViewController?.dismiss(animated: true, completion: nil); return
        }

        var filename: String? = given(info[.phAsset] as? PHAsset) { ($0.value(forKey: "filename")) as? String }
        // Fix extension. The actual image where sending is a JPG, and unfortunately the BE atm still relies on the file extension to determine file type.
        filename = filename?.replacingOccurrences(of: ".heic", with: ".jpg", options: .caseInsensitive)

        let completion: ActionClosure = { [weak self] in
            picker.presentingViewController?.dismiss(animated: true, completion: {
                guard let self = self else { return }
                if let imageURL = info[.mediaURL] as? URL ?? info[.imageURL] as? URL {
                    self.didPickMediaURLs?([ imageURL ], [])
                }
                if let didPickDocumentData = self.didPickDocumentData {
                    let (data, filename, mime): (Data?, String, String) = {
                        if let imageURL = info[.imageURL] as? URL, imageURL.hasExtension(ofKind: .gif) {
                            let filename = filename ?? UUID().uuidString + "." + imageURL.pathExtension
                            let data = try? Data(contentsOf: imageURL)
                            return (data, filename, DocumentExtension.gif.mime)
                        } else {
                            let filename = filename ?? UUID().uuidString + ".jpg"
                            let data = self.automaticImageCompression ? image.compressedScaledImageData() : image.jpegData(compressionQuality: 1.0)
                            return (data, filename, DocumentExtension.jpeg.mime)
                        }
                    }()
                    if let document = DocumentData(data: data, mime: mime, filename: filename) {
                        didPickDocumentData([ document ], [])
                    }
                }
                self.didPickImages?([ image ], [])
            })
        }

        if picker.sourceType == .photoLibrary, !picker.allowsEditing, filename?.hasExtension(ofKind: .gif) == false {
            let confirmationVC = PhotoConfirmationPopUpVC(image: image, chooseAction: completion)
            picker.present(confirmationVC, animated: true, completion: nil)
        } else {
            completion()
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

// Declare a global var to produce a unique address as the associated object handle
var imagePickerAssociatedObjectHandler: UInt8 = 0

private extension UIImagePickerController {
    var pgImagePicker: TTImagePickerController {
        get { return objc_getAssociatedObject(self, &imagePickerAssociatedObjectHandler) as! TTImagePickerController }
        set { objc_setAssociatedObject(self, &imagePickerAssociatedObjectHandler, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

final class CroppableImagePickerController : TTImagePickerController {
    override class var isCroppable: Bool { return true }
}
