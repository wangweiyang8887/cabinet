// Copyright © 2021 evan. All rights reserved.

import UIKit

class BaseViewController : UIViewController {
    
    class var isLandscape: Bool { return false }
    var navigationBarStyle: NavigationBarStyle { return .whiteWithoutShadow }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cabinetWhite
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    deinit {
        print("\(Self.self) deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backButton.isHidden = navigationController?.viewControllers.count == 1
        guard let baseNavigationController = self.navigationController as? BaseNavigationController else { return }
        baseNavigationController.navBarStyle = navigationBarStyle
    }
    
    private lazy var backButton: UIButton = {
        let result = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        result.setImage(UIImage(named: "nav_back_white")?.withRenderingMode(.alwaysTemplate), for: .normal)
        result.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        result.addTapHandler { [unowned self] in self.navigationController?.popViewController(animated: true) }
        return result
    }()
        
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if Self.isLandscape {
            return .landscape
        } else {
            return .portrait
        }
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if Self.isLandscape {
            return .landscapeRight
        } else {
            return .portrait
        }
    }
    
    override var shouldAutorotate: Bool { return true }
}
