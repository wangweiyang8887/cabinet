// Copyright © 2021 evan. All rights reserved.

import UIKit
import CoreLocation

class HomePageVC : BaseCollectionViewController {
    private var settings: [Setting] { return FileManager.getSettings() }
    var currentWeather: CurrentWeather? { didSet { updateContent() } }
    var daily: DailyModel? { didSet { updateContent() } }
    var ssqModel: LotteryModel?
    var dltModel: LotteryModel?
    override var navigationBarStyle: NavigationBarStyle { return .whiteWithoutShadow }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.ttDelegate = self
        collectionView.sections += BaseSection(createSectionContentItem(), margins: UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0))
        collectionView.refreshHeader = { [unowned self] in self.fetchData() }
        navigationItem.leftBarButtonItem = UIBarButtonItem.supportButtonItem()
        navigationItem.rightBarButtonItem = UIBarButtonItem.settingButtonItem { [unowned self] in
            self.collectionView.sections = [ BaseSection(self.createSectionContentItem(), margins: UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)) ]
            self.collectionView.reloadData()
        }
        fetchData()
    }
    
    private func fetchData() {
        LocationManager.shared.start { [weak self] location, address in
            guard let self = self else { return }
            self.weatherRow.city = address
            guard let coordinate = location?.coordinate else { return }
            UserDefaults.shared[.userCoordinate] = "\(coordinate.longitude),\(coordinate.latitude)"
            UserDefaults.shared[.userAddress] = address
            Server.fetchCurrentWeather(with: coordinate).onSuccess { [weak self] weather in
                self?.currentWeather = weather
            }
        }
        var operations: [AnyOperation] = []
        operations += Server.fetchDailyReport().onSuccess { [weak self] result in
            guard let self = self else { return }
            if let shuffledDay = UserDefaults.shared[.shuffledDay], shuffledDay != CalendarDate.today(in: .current).day {
                result.sentence.shuffle()
                result.daily.shuffle()
                result.red.shuffle()
                result.green.shuffle()
                UserDefaults.shared[.shuffledDay] = CalendarDate.today(in: .current).day
            }
            self.daily = result
            self.ssqModel = result.lottery.first
            self.dltModel = result.lottery.last
        }
        operations += Server.fetchLottery(with: "ssq").onSuccess { [weak self] result in
            self?.lotteryRow.ssqModel = result
        }
        operations += Server.fetchLottery(with: "dlt").onSuccess { [weak self] result in
            self?.lotteryRow.dltModel = result
        }
        operations += Server.fetchChieseCalendar(by: Date().cabinetDateFormatted()).onSuccess { [weak self] result in
            self?.calendarRow.chineseCalendar = result
        }
        OperationGroup(operations).onCompletion { [weak self] _ in
            guard let self = self else { return }
            if self.lotteryRow.ssqModel?.lottery_id.trimmedNilIfEmpty == nil {
                self.lotteryRow.ssqModel = self.ssqModel
            }
            if self.lotteryRow.dltModel?.lottery_id.trimmedNilIfEmpty == nil {
                self.lotteryRow.dltModel = self.dltModel
            }
            self.collectionView.endRefresh()
            self.collectionView.reloadData()
        }
    }
    
    override func updateContentInset() {
        super.updateContentInset()
        collectionView.contentInset.bottom = 16 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    private func createSectionContentItem() -> [SectionContentItem] {
        let items = settings.filter { $0.isEnabled }.compactMap { itemByKind(with: $0.kind) }
        return [ titleRow ] + items
    }
    
    private func itemByKind(with kind: Setting.Kind) -> SectionContentItem? {
        switch kind {
        case .weather: return weatherRow
        case .calendar: return calendarRow
        case .daily: return dailyRow
        case .clock: return clockRow
        case .lottery: return lotteryRow
        }
    }
    
    private func updateContent() {
        if let weather = currentWeather {
            weatherRow.weather = weather
        }
        if let daily = daily {
            calendarRow.daily = daily
            let random = Int.random(in: 0..<daily.sentence.count)
            dailyRow.title = daily.sentence[ifPresent: random]
        }
    }
    
    // MARK: Components
    private lazy var titleRow: TextRow = {
        let result = TextRow()
        result.backgroundColor = .clear
        result.text = "Cabinet"
        result.font = .systemFont(ofSize: 32, weight: .bold)
        result.textColor = .cabinetBlack
        result.edgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        return result
    }()
    
    private lazy var weatherRow: CurrentWeatherRow = {
        let result = CurrentWeatherRow()
        result.eventModel = self.currentEvent
        result.reminderHandler = { [unowned self] in
            let vc = ReminderVC()
            vc.completion = { [unowned self] in self.weatherRow.eventModel = self.currentEvent }
            self.navigationController?.pushViewController(vc, animated: true) }
        return result
    }()
    
    private lazy var calendarRow = CalendarRow()
    private lazy var dailyRow = DailyRow()
    private lazy var clockRow = ClockRow()
    private lazy var lotteryRow = LotteryRow()
}

extension HomePageVC : BaseCollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        title = y >= 50 ? "Cabinet" : ""
    }
}

extension HomePageVC {
    var currentEvent: EventModel {
        let result = EventModel()
        result.name = UserDefaults.shared[.eventName]
        result.date = UserDefaults.shared[.eventDate]
        return result
    }
}

extension Server {
    static func fetchCurrentWeather(with location: CLLocationCoordinate2D) -> Operation<CurrentWeather> {
        let parameters = [ "location":"\(location.longitude),\(location.latitude)", "key":"2e977cafcd7243019922c2e87d1b5e28" ]
        return Server.fire(.get, .weather, parameters: parameters)
    }
    
    static func fetchDailyReport() -> Operation<DailyModel> {
        return Server.fire(.daily)
    }
}
