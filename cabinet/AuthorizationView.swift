// Copyright © 2021 evan. All rights reserved.

@objc
enum AuthorizationViewKey: Int {
    case camera, photoLibrary, microphone
}

final class AuthorizationView : UIView {
    @objc
    class func showAlert(with key: AuthorizationViewKey, on viewController: UIViewController = UIViewController.current(), completion: ActionClosure? = nil) {
        let authorization: Authorization = {
            switch key {
            case .camera: return CameraAuthorization.shared
            case .photoLibrary: return PhotoLibraryAuthorization.shared
            case .microphone: return MicAuthorization.shared
            }
        }()
        guard authorization.status != .authorized else { completion?(); return }
        authorization.authorizedHandler = completion
        if authorization.status == .notDetermined {
            authorization.request()
        } else {
            // TODO: 可以增加跳转到设置页面
            UIAlertController.presentAlert(title: "温馨提示", message: "您还没有授权访问相册,请去授权!", style: .alert, actions: [ .cancel ])
        }
    }
    
    private class func openSettings() {
        UIApplication.shared.openSettings()
    }
}

extension UIApplication {
    func openSettings() {
        open(URL(string: UIApplication.openSettingsURLString)!)
    }
}
