// Copyright © 2021 evan. All rights reserved.

final class SettingVC : BaseViewController {
    private var appendingUrl: URL? = FileManager.getAppendingUrl()
    private var settings: [Setting] = [] { didSet { tableView.reloadData() } }
    private var mainUrl = Bundle.main.url(forResource: "Setting", withExtension: "json")
    
    override var navigationBarStyle: NavigationBarStyle { return .white }
    
    var settingChangedHandler: ActionClosure?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.addSubview(tableView, pinningEdges: .all)
        tableView.backgroundColor = .cabinetWhite
        settings = FileManager.getSettings()
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
        case weather = 1, calendar, daily, clock
    }
}
