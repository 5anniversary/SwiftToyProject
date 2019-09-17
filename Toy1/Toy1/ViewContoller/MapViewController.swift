//
//  MapViewController.swift
//  Toy1
//
//  Created by Junhyeon on 2019/09/17.
//  Copyright © 2019 Junhyeon. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit


class MapViewController: UIViewController {

    //  MARK: - Variable and Properties
    var locationManager = CLLocationManager()
    let regionInMeters: Double = 1000
    var previousLocation: CLLocation?
    var directionsArray: [MKDirections] = []
    var sdf : Int!

    
    //  MARK: - Views
    let mapView : MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.mapType = .standard
        map.isZoomEnabled = true
        map.isScrollEnabled = true

        return map
    }()

    let pinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pin")
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    let goButton = UIButton()
    let resetButton = UIButton()
    let myLocationLabel = UILabel()
    let pinLocationLabel = UILabel()

    
    
    //  MARK: -Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        goButton.setButton(translatesAutoresizingMaskIntoConstraints: false, setTitle: "go", setBackground: UIColor.blue, setTintColor: UIColor.white)
        resetButton.setButton(translatesAutoresizingMaskIntoConstraints: false, setTitle: "reset", setBackground: UIColor.blue, setTintColor: UIColor.white)
        pinLocationLabel.setLabel(translatesAutoresizingMaskIntoConstraints: false, setText: "pinLocation", setBackground: UIColor.black, setTextColor: UIColor.white, textAlignment: .center)
        myLocationLabel.setLabel(translatesAutoresizingMaskIntoConstraints: false, setText: "MyLocation", setBackground: UIColor.black, setTextColor: UIColor.white, textAlignment: .center)
            
        view.addSubview(mapView)
        view.addSubview(pinImageView)
        view.addSubview(goButton)
        view.addSubview(resetButton)
        view.addSubview(myLocationLabel)
        view.addSubview(pinLocationLabel)
        
        setLayout()
    }
    
    // MARK: -Helper funcs
    
    func resetMapView(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
    }
    
    @objc
    func goButtonTapped() {
        getDirections()
    }
    
    func setLayout() {
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -120),
            mapView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0),
            mapView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0),
            
            pinLocationLabel.leftAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.leftAnchor, constant: 0),
            pinLocationLabel.rightAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.rightAnchor, constant: 0),
            pinLocationLabel.bottomAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.bottomAnchor, constant: 60),
            pinLocationLabel.heightAnchor.constraint(equalToConstant: 60),
            
            myLocationLabel.leftAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.leftAnchor, constant: 0),
            myLocationLabel.rightAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.rightAnchor, constant: 0),
            myLocationLabel.bottomAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.bottomAnchor, constant: 120),
            myLocationLabel.heightAnchor.constraint(equalToConstant: 60),
            
            pinImageView.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
            pinImageView.centerYAnchor.constraint(equalTo: mapView.centerYAnchor, constant: -20),
            
            goButton.rightAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.rightAnchor, constant: -30),
            goButton.bottomAnchor.constraint(equalTo: pinLocationLabel.topAnchor, constant: -30),
            goButton.widthAnchor.constraint(equalToConstant: 50),
            goButton.heightAnchor.constraint(equalToConstant: 50),
            
            resetButton.rightAnchor.constraint(equalTo: goButton.safeAreaLayoutGuide.leftAnchor, constant: -10),
            resetButton.bottomAnchor.constraint(equalTo: pinLocationLabel.topAnchor, constant: -30),
            resetButton.widthAnchor.constraint(equalToConstant: 50),
            resetButton.heightAnchor.constraint(equalToConstant: 50),
            
            ])
        
        goButton.layer.cornerRadius = 5
        resetButton.layer.cornerRadius = 5

    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        mapView.delegate = self
    }

    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }

    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
    
            setupLocationManager()
            checkLocationAuthorization()
            
        } else {
            print("Please turn on location service or GPS")
        }
    }

    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            startTrackingUserLocation()
            break
        case .denied:
            // Show alert instructing them how to turn on permissionss
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .authorizedAlways:
            break
        default:
            break
        }
    }

    func startTrackingUserLocation() {
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
        
    }
    
    func getDirections() {
        guard let location = locationManager.location?.coordinate else {
            return
        }
        
        let request = createDirectionsRequest(from: location)
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions)
        
        directions.calculate { [unowned self](response, error) in
            guard let response = response else { return }
            
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        let destinationCoordinate = getCenterLocation(for: mapView).coordinate
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
        
    }

}

// MARK: - CLLocationManagerDelegate
extension MapViewController : CLLocationManagerDelegate {

//        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//
//            self.locationLabel.text = "Error while updating location " + error.localizedDescription
//
//        }
//
//        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//            CLGeocoder().reverseGeocodeLocation(locations.first!) { (placemarks, error) in
//                guard error == nil else {
//                    self.locationLabel.text = "Reverse geocoder failed with error" + error!.localizedDescription
//                    return
//                }
//                if placemarks!.count > 0 {
//                    let pm = placemarks!.first
//                    self.displayLocationInfo(pm)
//                } else {
//                    self.locationLabel.text = "Problem with the data received from geocoder"
//                }
//            }
//        }
//
//        func displayLocationInfo(_ placemark: CLPlacemark?) {
//            if let containsPlacemark = placemark {
//                //stop updating location to save battery life
//                locationManager.stopUpdatingLocation()
//
//                let country = (containsPlacemark.country != nil) ? containsPlacemark.country : ""   // 나라
//                let administrativeArea = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""  //시, 군, 구
//                let locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""    // 구
//                let street = (containsPlacemark.thoroughfare != nil) ?containsPlacemark.thoroughfare : "" // 도로명
//                let postalCode = (containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode : ""  // 우편번호
//
//                self.locationLabel.text = country! + " " + administrativeArea! + " " + locality! + " " + street! + " " + postalCode!
//            }
//        }
}

// MARK: - MKMapViewDelegate
extension MapViewController : MKMapViewDelegate {
    
}
