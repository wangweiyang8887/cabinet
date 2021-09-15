// Copyright © 2021 evan. All rights reserved.

import UIKit

final class ReminderVC : BaseCollectionViewController {
    var completion: ActionClosure?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "倒数日"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        collectionView.sections += BaseSection([ reminderRow, SpacerRow(height: 32), eventEditorRow, dateRow ])
    }

    // MARK: Components
    private lazy var saveButton: TTButton = {
        let result = TTButton()
        result.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        result.setTitle("保存", for: .normal)
        result.setTitleColor(.cabinetBlack, for: .normal)
        result.addTapHandler { [unowned self] in
            if let name = self.eventEditorRow.value {
                UserDefaults.shared[.eventName] = name
            }
            if let date = self.dateRow.value {
                UserDefaults.shared[.eventDate] = date
            }
            self.completion?()
            self.popOrDismissSelf()
        }
        return result
    }()
    
    private lazy var reminderRow: ReminderRow = {
        let result = ReminderRow()
        result.title = UserDefaults.shared[.eventName]
        result.date = UserDefaults.shared[.eventDate]
        result.selectionHandler = { [unowned self] in self.view.endEditing(true) }
        return result
    }()
    
    private lazy var eventEditorRow: StringEditorRow<String?> = {
        let result = StringEditorRow<String?>()
        result.title = "事件名称"
        let editor = TrimmedStringEditor()
        editor.placeholder = "请输入事件名称"
        editor.placeholderAttributer = { $0.withColor(.nonStandardColor(withRGBHex: 0xC8C8C8)) }
        editor.charLimit = 14
        result.editor = editor
        result.bottomSeparatorMode = .show
        result.valueEditedHandler = { [unowned self] in self.reminderRow.title = $0 }
        return result
    }()
    
    private lazy var dateRow: ModalEditorRow<String?> = {
        let result = ModalEditorRow<String?>()
        result.title = "目标日期"
        result.valueTextColor = .cabinetBlack
        result.isPlaceholder = { $0 == nil }
        result.formatter = { $0 ?? "请选择" }
        result.selectionHandler = { [unowned self] in self.pickerVC.show() }
        return result
    }()
    
    private lazy var pickerVC: DatePickerVC = {
        let result = DatePickerVC(title: "请选择日期", dateType: .yearMonthDay, timeZone: .current)
        result.valueEditedHandler = { date in
            let value = date.formatted(using: DateFormatter(dateFormat: "yyyy.MM.dd"))
            self.dateRow.value = value
            self.dateRow.updateValueLabel()
            self.reminderRow.date = value
        }
        return result
    }()
}
