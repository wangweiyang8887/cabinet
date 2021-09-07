// Copyright © 2021 evan. All rights reserved.

import UIKit
import CoreLocation

class HomePageVC : BaseCollectionViewController {
    var currentWeather: CurrentWeather? { didSet { updateContent() } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.sections += BaseSection([ weatherRow, dateRow ])
        LocationManager.shared.start { [weak self] location, address in
            guard let self = self else { return }
            self.weatherRow.city = address
            guard let coordinate = location?.coordinate else { return }
            Server.fetchCurrentWeather(with: coordinate).onSuccess { [weak self] weather in
                self?.currentWeather = weather
            }
        }
    }
    
    private func updateContent() {
        guard let weather = currentWeather else { return }
        weatherRow.weather = weather
        collectionView.reloadData()
    }
    
    // MARK: Components
    private lazy var weatherRow = CurrentWeatherRow()
    private lazy var dateRow = CurrentDateRow()
}

extension Server {
    static func fetchCurrentWeather(with location: CLLocationCoordinate2D) -> Operation<CurrentWeather> {
        let parameters = [ "location":"\(location.longitude),\(location.latitude)", "key":"2e977cafcd7243019922c2e87d1b5e28" ]
        return Server.fire(.get, .weather, parameters: parameters)
    }
}
