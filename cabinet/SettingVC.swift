// Copyright © 2021 evan. All rights reserved.

final class SettingVC : BaseViewController {
    private var appendingUrl: URL?
    private var settings: [Setting] = [] { didSet { tableView.reloadData() } }
    private var mainUrl = Bundle.main.url(forResource: "Setting", withExtension: "json")
    var settingChangedHandler: ActionClosure?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.addSubview(tableView, pinningEdges: .all)
        getSettings()
    }
    
    private lazy var tableView: UITableView = {
        let result = UITableView(frame: .zero, style: .grouped)
        result.delegate = self
        result.dataSource = self
        result.showsVerticalScrollIndicator = false
        result.registerCell(withClass: SettingTableViewCell.self)
        return result
    }()
}

extension SettingVC : UITableViewDelegate, UITableViewDataSource {
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
    private func getSettings() {
        guard let mainUrl = mainUrl else { return }
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            appendingUrl = documentDirectory.appendingPathComponent("Setting.json")
            loadFile(mainPath: mainUrl, appendingPath: appendingUrl!)
        } catch {
            print(error)
        }
    }
    
    private func loadFile(mainPath: URL, appendingPath: URL){
        if FileManager.default.fileExists(atPath: appendingPath.path){
            decodeData(pathName: appendingPath)
            if settings.isEmpty {
                decodeData(pathName: mainPath)
            }
        } else {
            decodeData(pathName: mainPath)
        }
    }
    
    private func decodeData(pathName: URL){
        do {
            let jsonData = try Data(contentsOf: pathName)
            let decoder = JSONDecoder()
            settings = try decoder.decode([Setting].self, from: jsonData)
        } catch {}
    }
    
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
}
