// Copyright © 2021 evan. All rights reserved.

final class SettingVC : BaseViewController {
    private var appendingUrl: URL? = FileManager.getAppendingUrl()
    private var settings: [Setting] = [] { didSet { tableView.reloadData() } }
    private var mainUrl = Bundle.main.url(forResource: "Setting", withExtension: "json")
    private var isBeginMove: Bool = false
    private var currentMoveCell: SettingTableViewCell?
    
    override var navigationBarStyle: NavigationBarStyle { return .white }
    
    var settingChangedHandler: ActionClosure?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "首页排版"
        view.addSubview(tableView, pinningEdges: .all)
        tableView.backgroundColor = .cabinetWhite
        settings = FileManager.getSettings()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sortButton)
    }
    
    private lazy var tableView: UITableView = {
        let result = UITableView(frame: .zero, style: .grouped)
        result.delegate = self
        result.dataSource = self
        result.showsVerticalScrollIndicator = false
        result.separatorStyle = .none
        result.registerCell(withClass: SettingTableViewCell.self)
        return result
    }()
    
    private lazy var sortButton: TTButton = {
        let result = TTButton()
        result.title = "排序"
        result.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        result.setTitleColor(.cabinetBlack, for: .normal)
        result.addTapHandler { [unowned self] in
            self.tableView.isEditing.toggle()
            self.sortButton.title = self.tableView.isEditing ? "完成" : "排序"
        }
        return result
    }()
}

extension SettingVC : UITableViewDelegate, UITableViewDataSource {
    /// Delete the header and footer view of section
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return 0.000001 }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return 0.000001 }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? { return nil }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? { return nil }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(SettingTableViewCell.self, for: indexPath)
        cell.model = settings[indexPath.row]
        cell.tonggleHandler = { [unowned self] in
            self.settings[indexPath.row].isEnabled = $0
            guard let url = appendingUrl else { return }
            self.writeToFile(location: url)
            self.settingChangedHandler?()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let setting = settings[sourceIndexPath.row]
        settings.remove(at: sourceIndexPath.row)
        settings.insert(setting, at: destinationIndexPath.row)
        guard let url = appendingUrl else { return }
        self.writeToFile(location: url)
        self.settingChangedHandler?()
    }
}

extension SettingVC {
    private func writeToFile(location: URL) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let JsonData = try encoder.encode(settings)
            try JsonData.write(to: location)
        } catch {}
    }
}

struct Setting : Codable {
    var title: String
    var isEnabled: Bool
    var kind: Kind
    
    enum Kind : Int, Codable {
        case weather = 1, calendar, daily, clock, lottery
    }
}
