//
//  ViewController.swift
//  RunMapGB
//
//  Created by emil kurbanov on 27.04.2022.
//

import UIKit
import GoogleMaps
import RealmSwift
import CoreLocation
import Realm
import RxSwift
import RxCocoa
import AVFoundation

enum MarkerSelected {
    case autoMarker
    case manualMarker
}
@IBDesignable class MapController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var startRoute: UIButton!
    @IBOutlet weak var cleanRoute: UIButton!
    @IBOutlet weak var trackingStop: UIButton!
    @IBOutlet weak var lastRouteOutlet: UIButton!
    
    var usselesExampleariable = ""
    
    let coordinate = CLLocationCoordinate2D(latitude: 37.34033264974476, longitude: -122.06892632102273)
    var marker: GMSMarker?
    var manualMarker: GMSMarker?
    var geoCoder: CLGeocoder?
    var route: GMSPolyline?
   // var locationManager: CLLocationManager?
    var routePath: GMSMutablePath?
    var locationsArray = [CLLocationCoordinate2D]()
    var countTap: Int = 1
    let realm = try! Realm()
    var realmRoutePoint: Results<ModelRealm>!
    var flag: Bool = false
    let locationManager = LocationManager()
    let disposeBag = DisposeBag()
    var onTakePicture: ((UIImage) -> Void)?
    var realmPhotoMarker: Results<PhotoMarker>!
    var photoMarker = PhotoMarker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButton()
        configureMap()
        configureLocationManager()
    }
    
    func addMarker(_ markerType: MarkerSelected, _ coordinate: CLLocationCoordinate2D) {
        
        switch markerType {
        case .autoMarker:
            marker = GMSMarker(position: coordinate)
            marker?.icon = GMSMarker.markerImage(with: .systemPink)
            marker?.title = "Auto Position"
            marker?.snippet = "Actual selected auto marker"
            marker?.map = mapView
            locationsArray.append(coordinate)
            //makeMapPath(locationsArray)
            
        case .manualMarker:
            manualMarker = GMSMarker(position: coordinate)
            manualMarker?.icon = GMSMarker.markerImage(with: .green)
            manualMarker?.title = "Manual Position"
            manualMarker?.snippet = "Actual selected manual marker"
            manualMarker?.map = mapView
        }
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
            locationManager.manager.requestLocation()
           //  locationManager?.requestLocation()
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
            locationManager.startUpdatingLocation()
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
        self.locationManager.location
        .asObservable()
        .bind { [weak self] observedLocation in
            guard let self = self else { return }
            guard let observedLocation = observedLocation else { return }
            self.routePath?.add(observedLocation.coordinate)
            self.route?.path = self.routePath
            
            let position = GMSCameraPosition(target: observedLocation.coordinate, zoom: 15)
            self.mapView.animate(to: position)
        }
        .disposed(by: disposeBag)
           
        
       /* locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.activityType = .airborne*/
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
        locationManager.stopUpdatingLocation()
        
        route?.map = nil
        route = nil
    }
    
    
    @IBAction func lastRoute(_ sender: Any) {
        if flag == true {
            let alert = UIAlertController(title: "Внимание", message: "В данный момент идет запись маршрута, если вы нажмете ОК, все данные этого маршрута будут потеряны! ", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.locationManager.stopUpdatingLocation()
                self.route?.map = nil
                self.route = nil
                self.flag = false
                self.showRoute()
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.showRoute()
        }
 
        }
        
    @IBAction func makePhotoButtonDidTapped(_ sender: Any) {
       // onTakePicture()
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true)
        
    }
}
    

    


extension MapController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        addMarker(.manualMarker, coordinate)
       /* print(coordinate)
        let manulMarker = GMSMarker(position: coordinate)
        manulMarker.map = mapView
        
        if geoCoder == nil {
            geoCoder = CLGeocoder()
        }
        
        geoCoder?.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), completionHandler: { places, error in
            print(places?.last as Any)
            print(error as Any)
        })*/
    }
}

extension MapController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            guard let image = self.extractImage(from: info) else { return }
            self.onTakePicture?(image)
            
            self.photoMarker.photo = image
            let photoMarker = self.photoMarker
            let realm = self.realm
                    
            try! realm.write {
                realm.add(photoMarker)
            }
        }
    }
    
    private func extractImage(from info: [String: Any]) -> UIImage? {
        if let image = info[UIImagePickerController.InfoKey.editedImage.rawValue] as? UIImage {
            return image
        } else if let image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage {
            return image
        } else {
            return nil
        }
    }
}

/*
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
*/


