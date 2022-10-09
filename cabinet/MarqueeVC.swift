// Copyright © 2021 evan. All rights reserved.

class MarqueeVC : BaseViewController {
    override class var isLandscape: Bool { return true }
    private var isTouching: Bool = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(marqueeLabel, pinningEdges: .all, withInsets: UIEdgeInsets(horizontal: 0, vertical: 24))
        perform(#selector(hide), with: self, afterDelay: 3, inModes: [ .common ])
        view.addSubview(toolView, pinningEdges: [ .left, .right, .top ])
    }
    
    @objc func hide() {
        guard !isTouching else { return }
        UIView.animate(withDuration: TTDuration.default) {
            self.toolView.alpha = 0
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: TTDuration.default) {
            self.toolView.alpha = 1
        }
        isTouching = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isTouching = false
        perform(#selector(hide), with: self, afterDelay: 3, inModes: [ .common ])
    }
    
    private lazy var toolView: UIView = {
        let result = UIView()
        result.backgroundColor = .clear
        result.constrainHeight(to: 68)
        let stackView = UIStackView(axis: .horizontal, arrangedSubviews: [ closeButton, UIView() ])
        result.addSubview(stackView, pinningEdges: .all, withInsets: UIEdgeInsets(uniform: 12))
        return result
    }()
    
    private lazy var closeButton: UIButton = {
        let result = UIButton(type: .custom)
        result.setImage(UIImage(named: "18-close")?.tinted(with: .white), for: .normal)
        result.addTapHandler { [unowned self] in self.dismissSelf() }
        return result
    }()
    
    private lazy var marqueeLabel: MarqueeLabel = {
        let result = MarqueeLabel(frame: .zero, scrollRate: .random(in: 25...60), fadeWidth: 0)
        result.text = "Taylor Swift Taylor Swift Taylor Swift Taylor Swift"
        result.font = .systemFont(ofSize: 96, weight: .bold)
        result.isMarqueeEnabled = true
        result.labelShouldAlwaysScroll = true
        result.textColor = .cabinetWhite
        result.textAlignment = .center
        return result
    }()
}
