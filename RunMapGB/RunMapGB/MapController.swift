//
//  ViewController.swift
//  RunMapGB
//
//  Created by emil kurbanov on 27.04.2022.
//

import UIKit
import GoogleMaps
import RealmSwift


@IBDesignable class MapController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var startRoute: UIButton!
    @IBOutlet weak var cleanRoute: UIButton!
    @IBOutlet weak var trackingStop: UIButton!
    @IBOutlet weak var lastRouteOutlet: UIButton!
    
    
    let coordinate = CLLocationCoordinate2D(latitude: 37.34033264974476, longitude: -122.06892632102273)
    var marker: GMSMarker?
    var geoCoder: CLGeocoder?
    var route: GMSPolyline?
    var locationManager: CLLocationManager?
    var routePath: GMSMutablePath?
    var countTap: Int = 1
    var realm = try! Realm()
    var realmRoutePoint: Results<ModelRealm>!
    var flag: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButton()
        configureMap()
        configureLocationManager()
    }
    
    
    func configureButton() {
        trackingStop.setTitle("Stop Tracking", for: .normal)
        trackingStop.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        startRoute.setImage(UIImage(systemName: "play"), for: .normal)
        cleanRoute.setImage(UIImage(systemName: "restart.circle"), for: .normal)
        cleanRoute.setTitle("Reset", for: .normal)
        startRoute.addTarget(self, action: #selector( multipleTap(sender:)), for: .touchUpInside)
    }

    func showRoute() {
        countTap += 1
        
        if countTap % 2 == 0 {
            startRoute.setImage(UIImage(systemName: "stop.circle"), for: .normal)
            realmRoutePoint = realm.objects(ModelRealm.self)
            guard realmRoutePoint != nil else {
                let alert = UIAlertController(title: "ВНИМАНИЕ!", message: "В базе нет никакого сохраненного маршрута", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                return  self.present(alert, animated: true, completion: nil)
            }
            flag = true
            locationManager?.requestLocation()
            route?.map = nil
            route = GMSPolyline()
            routePath = GMSMutablePath()
            route?.strokeWidth = 8
            route?.strokeColor = .green
            route?.geodesic = true
         
            /*realmRoutePoint.compactMap { [weak self] value in
                guard let self = self else {return}
                self.routePath?.add(CLLocationCoordinate2D(latitude: value.latitude, longitude: value.longitude))
            }*/
            for point in realmRoutePoint {
                routePath!.add(CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude))
            }
            route?.map = mapView
            locationManager?.startUpdatingLocation()
        } else {
            flag = true
            startRoute.setImage(UIImage(systemName: "play"), for: .normal)
           // startRoute.setTitle("play", for: .normal)
            guard let routePoints = routePath else { return }
             try! realm.write {
                realm.deleteAll()
            }
            for element in 0 ... (routePoints.count() - 1) {
                let routePoint = ModelRealm()
                routePoint.latitude = routePoints.coordinate(at: element).latitude
                routePoint.longitude = routePoints.coordinate(at: element).longitude
                try! realm.write {
                    realm.add(routePoint)
                }
            }
            print(realm.configuration.fileURL as Any)
            route?.map = nil
            route = nil
        }
    }
    
    @objc func multipleTap(sender: UIButton) {
        showRoute()
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
    
    
    @IBAction func eraseRoute(_ sender: Any) {
        
        flag = false
       // guard let routePoints = routePath else { return }
         try! realm.write {
              realm.deleteAll()
          }
        route?.map = nil
        route = nil
        
    }
    @IBAction func AddMarker(_ sender: Any) {
        if marker == nil {
            mapView.animate(toLocation: coordinate)
            addMarker()
        } else {
            removeMarker()
        }
    }
    
    @IBAction func StopTracking(_ sender: Any) {
        locationManager?.stopUpdatingLocation()
        
        route?.map = nil
        route = nil
    }
    
    
    @IBAction func lastRoute(_ sender: Any) {
        if flag == true {
            let alert = UIAlertController(title: "Внимание", message: "В данный момент идет запись маршрута, если вы нажмете ОК, все данные этого маршрута будут потеряны! ", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.locationManager?.stopUpdatingLocation()
                self.route?.map = nil
                self.route = nil
                self.flag = false
                self.showRoute()
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.showRoute()
        }
 
        
        /*self.realmRoutePoint?.map { value in
            lastRoutes.add(CLLocationCoordinate2D(latitude: value.latitude, longitude: value.longitude))
          
        }*/
        
        
            
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



