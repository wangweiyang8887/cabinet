// Copyright © 2021 evan. All rights reserved.

import UIKit

final class ReminderVC : BaseCollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "倒数日"
        collectionView.sections += BaseSection([ reminderRow, eventNameRow, eventEditorRow ])
    }
    
    private lazy var eventNameRow: TextRow = {
        let result = TextRow()
        result.text = "名称"
        result.textColor = .cabinetBlack
        result.edgeInsets = UIEdgeInsets(top: 32, left: 16, bottom: 0, right: 16)
        return result
    }()

    private lazy var reminderRow: ReminderRow = {
        let result = ReminderRow()
        result.title = UserDefaults.shared[.eventName]
        result.date = UserDefaults.shared[.eventDate]
        return result
    }()
    
    private lazy var eventEditorRow: StringEditorRow<String?> = {
        let result = StringEditorRow<String?>()
        result.title = "事件名称"
        let editor = TrimmedStringEditor()
        editor.placeholder = "请输入事件名称"
        editor.charLimit = 14
        result.editor = editor
        result.bottomSeparatorMode = .show
        result.valueEditedHandler = { [unowned self] in self.reminderRow.title = $0 }
        return result
    }()
    
    private lazy var dateRow: ModalEditorRow<String?> = {
        let result = ModalEditorRow<String?>()
        return result
    }()
}
