// Copyright © 2021 evan. All rights reserved.

import UIKit
import CoreLocation

class HomePageVC : BaseCollectionViewController {
    var currentWeather: CurrentWeather? { didSet { updateContent() } }
    var daily: DailyModel? { didSet { updateContent() } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.sections += BaseSection([ weatherRow, dateRow, dailyRow ])
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
        collectionView.reloadData()
    }
    
    // MARK: Components
    private lazy var weatherRow = CurrentWeatherRow()
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
