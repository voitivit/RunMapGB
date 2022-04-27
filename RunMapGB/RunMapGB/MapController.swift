//
//  ViewController.swift
//  RunMapGB
//
//  Created by emil kurbanov on 27.04.2022.
//

import UIKit
import GoogleMaps
class MapController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var startRoute: UIButton!
    
    let coordinate = CLLocationCoordinate2D(latitude: 37.34033264974476, longitude: -122.06892632102273)
    var marker: GMSMarker?
    var geoCoder: CLGeocoder?
    var route: GMSPolyline?
    var locationManager: CLLocationManager?
    var routePath: GMSMutablePath?
    var countTap: Int = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startRoute.addTarget(self, action: #selector( multipleTap(sender:)), for: .touchUpInside)
        configureMap()
        configureLocationManager()
    }
    
    @objc func multipleTap(sender: UIButton) {
        countTap += 1
        if countTap % 2 == 0 {
            locationManager?.requestLocation()
            startRoute.setTitle("Закончить маршрут", for: .normal)
            route?.map = nil
            route = GMSPolyline()
            route?.strokeWidth = 8
            route?.strokeColor = .green
            routePath = GMSMutablePath()
            route?.map = mapView
            
            locationManager?.startUpdatingLocation()
        } else  {
            startRoute.setTitle("Начать маршрут", for: .normal)
            route?.map = nil
            route = nil
        }
                
        
    }
    private func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.activityType = .airborne
    }
    
    private func configureMap() {
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 15)
        mapView.camera = camera
        mapView.isMyLocationEnabled = true
        
        mapView.delegate = self
        
        
    }
    private func addMarker() {
        marker = GMSMarker(position: coordinate)

        marker?.icon = GMSMarker.markerImage(with: .blue)
        marker?.title = "Маркер"
        marker?.snippet = "Новый маркер"
        
        marker?.map = mapView
    }
    
    private func removeMarker() {
        marker?.map = nil
        marker = nil
    }
    
    
    @IBAction func AddMarker(_ sender: Any) {
        if marker == nil {
            mapView.animate(toLocation: coordinate)
            addMarker()
        } else {
            removeMarker()
        }
    }
    }
    


extension MapController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print(coordinate)
        let manulMarker = GMSMarker(position: coordinate)
        manulMarker.map = mapView
        
        if geoCoder == nil {
            geoCoder = CLGeocoder()
        }
        
        geoCoder?.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), completionHandler: { places, error in
            print(places?.last as Any)
            print(error as Any)
        })
    }
}

extension MapController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        routePath?.add(location.coordinate)
        route?.path = routePath
        
        let position = GMSCameraPosition.camera(withTarget: location.coordinate , zoom: 15)
        mapView.animate(to: position)
        
        print(location.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}



