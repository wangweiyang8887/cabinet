// Copyright © 2021 evan. All rights reserved.

import UIKit
import CoreLocation

class HomePageVC : BaseCollectionViewController {
    var currentWeather: CurrentWeather? { didSet { updateContent() } }
    var daily: DailyModel? { didSet { updateContent() } }
    override var navigationBarStyle: NavigationBarStyle { return .transparent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.sections += BaseSection([ titleRow, weatherRow, dailyRow ], margins: UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0))
        LocationManager.shared.start { [weak self] location, address in
            guard let self = self else { return }
            self.weatherRow.city = address
            guard let coordinate = location?.coordinate else { return }
            Server.fetchCurrentWeather(with: coordinate).onSuccess { [weak self] weather in
                self?.currentWeather = weather
            }
        }
        Server.fetchDailyReport().onSuccess { [weak self] result in
            self?.daily = result
        }
    }
    
    private func updateContent() {
        if let weather = currentWeather {
            weatherRow.weather = weather
        }
        if let daily = daily {
            dailyRow.daily = daily
        }
        collectionView.reloadData()
    }
    
    // MARK: Components
    private lazy var titleRow: TextRow = {
        let result = TextRow()
        result.backgroundColor = .clear
        result.text = "Caibinet"
        result.font = .systemFont(ofSize: 32, weight: .bold)
        result.textColor = .cabinetBlack
        result.edgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        return result
    }()
    
    private lazy var weatherRow: CurrentWeatherRow = {
        let result = CurrentWeatherRow()
        result.reminderHandler = { [unowned self] in self.navigationController?.pushViewController(ReminderVC(), animated: true) }
        return result
    }()
    
    private lazy var dateRow = CurrentDateRow()
    private lazy var dailyRow = DailyRow()
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
