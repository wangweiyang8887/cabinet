// Copyright © 2021 evan. All rights reserved.

import CoreLocation

final class LocationManager : NSObject {
    static let shared = LocationManager()
    typealias LocationChanged = ((CLLocation?, String?) -> Void)
    
    private override init() {
        super.init()
        touch(manager)
    }
    
    private lazy var manager: CLLocationManager = {
        let result = CLLocationManager()
        result.distanceFilter = 300
        result.desiredAccuracy = kCLLocationAccuracyBest
        result.delegate = self
        result.requestWhenInUseAuthorization()
        return result
    }()
    
    var currentLacation: CLLocation?
    var locationChanged: LocationChanged?
    
    //更新位置
    func start(compeletion: LocationChanged?) {
        self.locationChanged = compeletion
        if CLLocationManager.locationServicesEnabled(){
            // 允许使用定位服务的话，开启定位服务更新
            manager.startUpdatingLocation()
            print("定位开始")
        }
    }
}

extension LocationManager : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 获取最新的坐标
        currentLacation = locations.last
        // 停止定位
        if locations.count > 0 {
            manager.stopUpdatingLocation()
            transformToCity()
        }
    }
        
    private func transformToCity() {
        guard let location = currentLacation else { return }
        let geocoder: CLGeocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemark, error in
            if let firstMark = placemark?.first {
                let city = given(firstMark.locality?.dropLast()) { String($0) }
                self?.locationChanged?(location, city)
            }
        }
    }
}
