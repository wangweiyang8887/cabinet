// Copyright © 2022 evan. All rights reserved.

import Foundation

class RandomChooseVC : BaseViewController, SheetPresentable {
    var model: GameModel = GameModel()
    var items: [String] { return model.items }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.style = .one
        view.addSubview(itemLabel, constrainedToCenterWithOffset: .zero)
        navigationItem.rightBarButtonItem = UIBarButtonItem.textButtonItem(with: "start", action: { [unowned self] in
            self.fire()
        })
        navigationItem.leftBarButtonItem = UIBarButtonItem.textButtonItem(with: "edit", action: {
            let nav = BaseNavigationController(rootViewController: EditCategoryVC())
            UIViewController.current().present(nav, animated: true, completion: nil)
        })
    }
    
    private lazy var itemLabel: CountingLabel = {
        let result = CountingLabel()
        result.text = "?????"
        result.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        result.textAlignment = .center
        result.constrainSize(to: CGSize(width: UIScreen.main.bounds.width - 32, height: 70))
        return result
    }()
    
    private func fire() {
        itemLabel.reset()
        itemLabel.count(from: 0, to: items.count - 1, duration: 3, animated: true)
        itemLabel.update { [unowned self] _, label in
            let values = self.items.indices.map { $0 }
            let value = self.randomValue(values)
            label.text = self.items[ifPresent: value]
        }
    }
    
    private func randomValue(_ items: [Int]) -> Int {
        let lock = NSLock()
        lock.lock()
        let value = items[Int.random(in: 0..<items.count)]
        lock.unlock()
        return value
    }
}
