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
        view.anchor().edgesToSuperview().activate()
        
        goButton.addTarget(self, action: #selector(goButtonTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(checkLocationServices), for: .touchUpInside)
        
        checkLocationServices()
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
    
    @IBAction func myLocationButtonDidTouch() {
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
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
        mapView.delegate = self
        mapView.showsUserLocation = true
    }

    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }

    @objc func checkLocationServices() {
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

        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

            self.myLocationLabel.text = "Error while updating location " + error.localizedDescription
            self.pinLocationLabel.text = "Error while updating location " + error.localizedDescription

        }

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            CLGeocoder().reverseGeocodeLocation(locations.first!) { (placemarks, error) in
                guard error == nil else {
                    self.myLocationLabel.text = "Reverse geocoder failed with error" + error!.localizedDescription
                    self.pinLocationLabel.text = "Reverse geocoder failed with error" + error!.localizedDescription
                    return
                }
                if placemarks!.count > 0 {
                    let pm = placemarks!.first
                    self.displayLocationInfo(pm)
                } else {
                    self.myLocationLabel.text = "Problem with the data received from geocoder"
                    self.pinLocationLabel.text = "Problem with the data received from geocoder"
                }
            }
        }

        func displayLocationInfo(_ placemark: CLPlacemark?) {
            if let containsPlacemark = placemark {
                //stop updating location to save battery life
                locationManager.stopUpdatingLocation()
                
                var num = 1

                let country = (containsPlacemark.country != nil) ? containsPlacemark.country : ""   // 나라
                let administrativeArea = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""  //시, 군, 구
                let locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""    // 구
                let street = (containsPlacemark.thoroughfare != nil) ?containsPlacemark.thoroughfare : "" // 도로명
                let postalCode = (containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode : ""  // 우편번호

                var stnum = String(num)
                
                self.myLocationLabel.text = country! + " " + administrativeArea! + " " + locality! + " " + street! + " " + postalCode! + " " + stnum
                num += 1
            }
        }
}

// MARK: - MKMapViewDelegate
extension MapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placeMarks, error) in
            guard let self = self else { return }
            
            guard let previousLocation = self.previousLocation else { return }
            guard center.distance(from: previousLocation) > 50 else { return }
            self.previousLocation = center
            
            geoCoder.cancelGeocode()
            
            if let _ = error {
                // TODO: Show alert informingthe user
                return
            }
            
            guard let placeMark = placeMarks?.first else {
                // TODO: Show alert informingthe user
                return
            }
            
            let streetNumber = placeMark.subThoroughfare ?? "" // 번지
            let streetName = placeMark.thoroughfare ?? "" // 도로명
            let countryName = placeMark.country ?? "" // 나라
            let stateName = placeMark.administrativeArea ?? "" // 도시
            let localName = placeMark.locality ?? "" // 구
            
            DispatchQueue.main.async {
                let location = "\(countryName) \(stateName) \(localName) \(streetName) \(streetNumber) "
                self.pinLocationLabel.text = location
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .blue
        
        return renderer
    }
}
