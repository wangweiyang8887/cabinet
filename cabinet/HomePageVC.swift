// Copyright © 2021 evan. All rights reserved.

import UIKit

class HomePageVC : BaseCollectionViewController {
    var currentWeather: CurrentWeather? { didSet { updateContent() } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.sections += BaseSection([ weatherRow, dateRow ])
        fetchData()
        LocationManager.shared.start { [weak self] _, address in
            self?.weatherRow.city = address
        }
    }
    
    private func fetchData() {
        Server.fetchCurrentWeather().onSuccess { [weak self] weather in
            self?.currentWeather = weather
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
    static func fetchCurrentWeather() -> Operation<CurrentWeather> {
        return Server.fire(.get, .weather)
    }
}
