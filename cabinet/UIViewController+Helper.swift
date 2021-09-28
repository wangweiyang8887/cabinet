// Copyright © 2021 evan. All rights reserved.

extension UIViewController {
    func showSetting(_ completion: ActionClosure?) {
        let vc = SettingVC()
        vc.settingChangedHandler = completion
        show(vc, animated: true)
    }
    
    func showSupporting() {
        let vc = SupportingVC()
        show(vc, animated: true)
    }
}
