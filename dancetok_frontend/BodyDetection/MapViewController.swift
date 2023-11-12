//
//  MapViewController.swift
//  BodyDetection
//
//  Created by Kewal Kishan Gokuldas on 11/12/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class MapViewController : UIViewController {
    
    let mapView : MKMapView = {
       let map = MKMapView()
        map.overrideUserInterfaceStyle = .dark
        return map
    }()
    
    @IBOutlet weak var titanBattle: UIButton!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMapConstraints()
       // titanBattle.isHidden = true
        
        locationManager.delegate = self
           locationManager.desiredAccuracy = kCLLocationAccuracyBest
           locationManager.requestWhenInUseAuthorization()
        
        addMultipleAnnotations()
        centerMapOnLocation()
        showUserLocation()
    }
    
    func showUserLocation() {
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow // This will follow the user's location
    }
    
    func setMapConstraints(){
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true

        
    }
    
    
    
    let locations = [
        (title: "Stanford Uni", latitude: 37.42783889180251, longitude: -122.17006000328483, contest : "Water - Tyla"),
        (title: "Stanford Medical", latitude: 37.4335793391047, longitude: -122.17054284457107,  contest : "Shape of you- Ed Sheeran"),
        // Add as many locations as you need
    ]
    func addMultipleAnnotations() {
      
        //37.4335793391047, -122.17054284457107
     



        for location in locations {
            let annotation = MKPointAnnotation()
            annotation.title = location.title
            annotation.subtitle = "Contest : \(location.contest)"
            annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            mapView.addAnnotation(annotation)
        }
    }
    
    func centerMapOnLocation() {
        let coordinate = CLLocationCoordinate2D(latitude: 37.4335793391047, longitude: -122.17054284457107) // Use the coordinate of your annotation
        let regionRadius: CLLocationDistance = 1000 // in meters
        let region = MKCoordinateRegion(center: coordinate,
                                        latitudinalMeters: regionRadius,
                                        longitudinalMeters: regionRadius)
        mapView.setRegion(region, animated: true)
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            switch status {
                case .authorizedWhenInUse, .authorizedAlways:
                    if CLLocationManager.locationServicesEnabled() {
                        locationManager.startUpdatingLocation()
                    }
                case .notDetermined:
                    locationManager.requestWhenInUseAuthorization() // or requestAlwaysAuthorization()
                case .restricted, .denied:
                    print("LOCATION DENIED/ Restricted ")
                    // Location services are not enabled; inform the user
                    // Show alert telling users how to turn on permissions
                @unknown default:
                    break
            }
        }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            calculateDistances(currentLocation: location)
            
            
        }
        if let location = locations.last {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            calculateDistances(currentLocation: location)
        }
        
    }
    
    func calculateDistances(currentLocation : CLLocation) {

            print(" calc called ");
            for marker in locations {
                let loc =  CLLocation(latitude: marker.latitude, longitude: marker.longitude)
                let distanceInMeters = currentLocation.distance(from: loc)
                print("The distance to the marker is \(distanceInMeters) meters.")
                if(distanceInMeters <= 50)
                {
                    
                }
                // Here, you can do something with the distance, like updating the UI
            }
        }
    
    
}
