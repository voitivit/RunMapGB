//
//  LocationManager.swift
//  RunMapGB
//
//  Created by emil kurbanov on 19.05.2022.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa

final class LocationManager: NSObject {
    static let instance = LocationManager()
    
     override init () {
        super.init()
        configureLocationManager()
    }
    let coordinate = CLLocationCoordinate2D(latitude: 37.34033264974476, longitude: -122.06892632102273)
    let manager = CLLocationManager()
    let  location: BehaviorRelay<CLLocation?> = BehaviorRelay(value: nil)
    
    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
    private func configureLocationManager() {
        //locationManager = CLLocationManager()
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.startMonitoringSignificantLocationChanges()
      //  locationManager.activityType = .airborne
    }
}
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location.accept(locations.last)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
