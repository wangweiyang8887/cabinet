// Copyright © 2021 evan. All rights reserved.

final class PhotoConfirmationPopUpVC : BaseViewController {
    let chooseAction: ActionClosure

    // MARK: Settings
    override var prefersStatusBarHidden: Bool { return true }

    // MARK: Initialization
    init(image: UIImage? = nil, data: Data? = nil, chooseAction: @escaping ActionClosure) {
        self.chooseAction = chooseAction
        super.init(nibName: nil, bundle: nil)
        self.image = image
    }

    required init?(coder: NSCoder) { 🔥 }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(scrollView, pinningEdgesToSafeArea: .all)

        imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1).isActive = true
        imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true

        let buttonHolderView = UIView()
        buttonHolderView.backgroundColor = .black
        buttonHolderView.constrainHeight(to: 64)
        view.addSubview(buttonHolderView, pinningEdgesToSafeArea: [ .left, .bottom, .right ])

        let cancelButton = UIButton(title: NSLocalizedString("Cancel", comment: ""), titleColor: .white, icon: nil) { [unowned self] in self.dismissSelf() }
        let chooseButton = UIButton(title: NSLocalizedString("Choose", comment: ""), titleColor: .white, icon: nil) { [unowned self] in self.chooseAction(); self.dismissSelf() }

        buttonHolderView.addSubview(cancelButton, pinningEdgesToSafeArea: [ .left, .bottom, .top ], withInsets: UIEdgeInsets(horizontal: 16, vertical: 0))
        buttonHolderView.addSubview(chooseButton, pinningEdgesToSafeArea: [ .right, .bottom, .top ], withInsets: UIEdgeInsets(horizontal: 16, vertical: 0))
    }

    // MARK: Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(wrapping: imageView, with: .zero)
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.delegate = self
        return scrollView
    }()

    private lazy var imageView: UIImageView = {
        let result = UIImageView()
        result.backgroundColor = .black
        result.contentMode = .scaleAspectFit
        return result
    }()

    // MARK: Accessors
    var image: UIImage? {
        set { imageView.image = newValue }
        get { return imageView.image }
    }
}

extension PhotoConfirmationPopUpVC : UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
