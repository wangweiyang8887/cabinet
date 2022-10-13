// Copyright © 2022 evan. All rights reserved.

class RandomEditSheetVC : BaseBottomSheetVC {
    private var minimum: Int = 0
    private var maximum: Int = 0
    
    static func show(with viewController: UIViewController, valueChangedHandler: ValueChangedHandler<ClosedRange<Int>>?) {
        let vc = RandomEditSheetVC(style: .action(cancelRowStyle: .done))
        vc.actionHandler = {
            let minimum = vc.minimum.constrained(toMax: vc.maximum)
            let maximum = vc.maximum.constrained(toMin: vc.minimum)
            let range = (minimum...maximum)
            valueChangedHandler?(range)
        }
        viewController.presentPanModal(vc)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.sections += BaseSection([ minimumEditorRow, maximumEditorRow ], margins: UIEdgeInsets(top: 8, left: 0, bottom: 80, right: 0))
    }
    
    private lazy var minimumEditorRow: StringEditorRow<String?> = {
        let result = StringEditorRow<String?>()
        result.margin = UIEdgeInsets(horizontal: 16, vertical: 8)
        result.backgroundColor = .cabinetLighterGray
        result.cornerRadius = 16
        result.title = "最小值"
        let editor = TrimmedStringEditor()
        editor.placeholder = "请输入最小值"
        editor.placeholderAttributer = { $0.withColor(.nonStandardColor(withRGBHex: 0xC8C8C8)) }
        editor.charLimit = 5
        editor.keyboardType = .numberPad
        result.editor = editor
        result.hideSeparators()
        result.valueEditedHandler = { [unowned self] value in self.minimum = given(value) { Int($0) } ?? 0 }
        return result
    }()
    
    private lazy var maximumEditorRow: StringEditorRow<String?> = {
        let result = StringEditorRow<String?>()
        result.margin = UIEdgeInsets(horizontal: 16, vertical: 16)
        result.backgroundColor = .cabinetLighterGray
        result.cornerRadius = 16
        result.title = "最大值"
        let editor = TrimmedStringEditor()
        editor.placeholder = "请输入最大值"
        editor.placeholderAttributer = { $0.withColor(.nonStandardColor(withRGBHex: 0xC8C8C8)) }
        editor.charLimit = 5
        editor.keyboardType = .numberPad
        result.editor = editor
        result.hideSeparators()
        result.valueEditedHandler = { [unowned self] value in self.maximum = given(value) { Int($0) } ?? 0 }
        return result
    }()
}
