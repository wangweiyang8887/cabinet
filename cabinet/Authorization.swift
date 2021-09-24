// Copyright © 2021 evan. All rights reserved.

import Photos

// MARK: - Authorization Status
enum AuthorizationStatus {
    case notDetermined, restricted, denied, authorized, limited
}

// MARK: - Authorization Delegate
protocol AuthorizationDelegate : AnyObject {
    func handleAuthorizationChanged(_ authorization: Authorization)
}

class Authorization : NSObject {
    var status: AuthorizationStatus { return .notDetermined }
    weak var delegate: AuthorizationDelegate?
    var authorizedHandler: ActionClosure? { didSet { if status == .authorized { authorizedHandler?() } } }
    func request() {}
    fileprivate func handleAuthorization() {
        if status == .authorized { authorizedHandler?() }
        delegate?.handleAuthorizationChanged(self)
    }
}

// MARK: - Camera Authorization
class CameraAuthorization : Authorization {
    static let shared = CameraAuthorization()
    private override init() { super.init() }
    
    override var status: AuthorizationStatus {
        let avStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch avStatus {
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        case .denied: return .denied
        case .authorized: return .authorized
        @unknown default: 🔥
        }
    }
    
    override func request() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] _ in
            DispatchQueue.main.async { self?.handleAuthorization() }
        })
    }
}

// MARK: - Photo Library Authorization
class PhotoLibraryAuthorization : Authorization {
    static let shared = PhotoLibraryAuthorization()
    private override init() { super.init() }
    
    override var status: AuthorizationStatus {
        let phStatus: PHAuthorizationStatus
        if #available(iOS 14, *) {
            phStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            phStatus = PHPhotoLibrary.authorizationStatus()
        }
        switch phStatus {
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        case .denied: return .denied
        case .authorized: return .authorized
        case .limited: return .authorized
        @unknown default: 🔥
        }
    }
    
    override func request() {
        PHPhotoLibrary.requestAuthorization { [weak self] _ in
            DispatchQueue.main.async { self?.handleAuthorization() }
        }
    }
}

// MARK: - Mic Authorization
class MicAuthorization : Authorization {
    static let shared = MicAuthorization()
    private override init() { super.init() }
    
    override var status: AuthorizationStatus {
        let audioStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        switch audioStatus {
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        case .denied: return .denied
        case .authorized: return .authorized
        @unknown default: 🔥
        }
    }
    
    override func request() {
        AVCaptureDevice.requestAccess(for: .audio) { [weak self] _ in
            DispatchQueue.main.async {
                if self?.status == .authorized { self?.authorizedHandler?() }
            }
        }
    }
}

