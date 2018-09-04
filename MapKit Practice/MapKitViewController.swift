//
//  MapKitViewController.swift
//  MapKit Practice
//
//  Created by Vigneshraj Sekar Babu on 9/3/18.
//  Copyright © 2018 Vigneshraj Sekar Babu. All rights reserved.
//  Referred from Sean Allen - Youtube - https://www.youtube.com/watch?v=WPpaAy73nJc

import UIKit
import MapKit
import CoreLocation

class MapKitViewController: UIViewController {
    
    let rangeToShowInMap: Double = 10000
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pinImageVIew: UIImageView!
    @IBOutlet weak var labelLocation: UILabel!
    var locationManager = CLLocationManager()
    
    var previousLocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        checkDeviceLocationService()
    }

    
    func checkDeviceLocationService() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuth()
        } else {
            //write code for when device location is not enabled
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    fileprivate func updateUserLocation() {
        //show user location is enabled in the storyboard for the mapView
        //mapView.showsUserLocation = true
        centerViewOnUserLocation()
        //the below line calls the didUpdateLocations whenever the location is updated
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    func checkLocationAuth() {
        switch  CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            updateUserLocation()
            break
        case .denied:
            // when the user denies the location access
            break
        case .notDetermined:
            // before user providing the app access
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            //parental controls may restrict uses to provide location accees
            break
        case .authorizedAlways:
            //do not use this unless critical
            break
        }
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegionMakeWithDistance(location, rangeToShowInMap, rangeToShowInMap)
            
            mapView.setRegion(region, animated: true)
        }
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
     return CLLocation(latitude: latitude, longitude: longitude)
    }

}

extension MapKitViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location updated")
//        guard let location = locations.last else { return }
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegionMakeWithDistance(center, rangeToShowInMap, rangeToShowInMap)
//        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //when the auth changes for the location manager
    }
    
}


extension MapKitViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        guard var previousLocation = previousLocation else { return }
        
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        guard center.distance(from: previousLocation) > 50 else { return }
        previousLocation = center
        geoCoder.reverseGeocodeLocation(center) { (placemark, error) in
            if let _ = error {
                //handle error
            }
            guard let placemark = placemark?.first else { return }
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            DispatchQueue.main.async {
                self.labelLocation.text = "\(streetNumber) \(streetName)"
            }
        }
    }
}



