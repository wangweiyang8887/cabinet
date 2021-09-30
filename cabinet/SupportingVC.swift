// Copyright © 2021 evan. All rights reserved.

final class SupportingVC : BaseCollectionViewController {
    override var navigationBarStyle: NavigationBarStyle { return .white }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Supporting"
        collectionView.sections += BaseSection([ commentRow, versionRow, feedbackRow, contactRow ])
    }
    
    private lazy var commentRow: PlainRow = {
        let result = PlainRow()
        result.title = "欢迎评分"
        result.subtitle = "😊"
        result.selectionHandler = {
            let url = URL(string: "https://apps.apple.com/cn/app/cabinet/id1585594199")!
            UIApplication.shared.open(url)
        }
        result.bottomSeparatorMode = .show
        return result
    }()
    
    private lazy var versionRow: PlainRow = {
        let result = PlainRow()
        result.title = "当前版本"
        result.subtitle = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!
        result.bottomSeparatorMode = .show
        return result
    }()
    
    private lazy var feedbackRow: PlainRow = {
        let result = PlainRow()
        result.title = "问题/意见"
        result.subtitle = "98708887@qq.com"
        return result
    }()
    
    private lazy var contactRow: PlainRow = {
        let result = PlainRow()
        result.title = "wechat_id"
        result.subtitle = "_evan0723"
        result.selectionHandler = {
            UIPasteboard.general.string = "_evan0723"
            let alertController = UIAlertController(title: "", message: "已添加到剪切板", preferredStyle: .alert)
            UIViewController.current().present(alertController, animated: true, completion: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    alertController.dismissSelf()
                }
            })
        }
        return result
    }()
}
