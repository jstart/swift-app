//
//  LocationManager.swift
//  Mesh
//
//  Created by Christopher Truman on 8/18/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import CoreLocation
import MapKit
import UIKit

typealias PlacemarkResult = (lat: Double, lon: Double, title: String, subtitle: String?)

class LocationManager : NSObject, CLLocationManagerDelegate, MKLocalSearchCompleterDelegate {
    
    static let shared = LocationManager()
    
    static var currentLocation : CLLocation?
    static var currentPlacemark : CLPlacemark?
    
    let geocoder = CLGeocoder()
    let manager = CLLocationManager()
    var searchResults = [MKLocalSearchCompletion]()
    let searchCompleter = MKLocalSearchCompleter()
    var searchCompletion = {}

    static var locationUpdate : ((CLLocation) -> Void)? = nil
    
    static func cityState() -> String{
        if currentPlacemark?.locality != nil && currentPlacemark?.administrativeArea != nil {
            return currentPlacemark!.locality! + ", " + currentPlacemark!.administrativeArea!
        }
        return ""
    }

    static func startTracking() {// -> (enabled: Bool, status: CLAuthorizationStatus) {
        shared.manager.delegate = shared
        shared.manager.distanceFilter = 10
        shared.manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        if CLLocationManager.locationServicesEnabled() {
            shared.manager.startMonitoringSignificantLocationChanges()
            shared.manager.requestLocation()
        }
        if CLLocationManager.authorizationStatus() == .notDetermined { shared.manager.requestWhenInUseAuthorization() }
        //return (CLLocationManager.locationServicesEnabled(), CLLocationManager.authorizationStatus())
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch (status) {
        case .authorizedWhenInUse: manager.startMonitoringSignificantLocationChanges(); break
        case .restricted, .denied:
            let alertController = UIAlertController.alert(
                title: "Location Access Disabled",
                message: "In order to match you with nearby users & events, please open this app's settings and set location access to 'When in use'.")
            
            let openAction = UIAlertAction("Open Settings") { (action) in
                guard let url = URL(string:UIApplicationOpenSettingsURLString) else { return }
                UIApplication.shared.openURL(url as URL)
            }
            alertController.addActions(UIAlertAction.cancel(), openAction)
            
            UIApplication.shared.keyWindow!.rootViewController!.present(alertController); break
        default: break }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) { }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        LocationManager.currentLocation = locations.first!
        LocationManager.locationUpdate?(locations.first!)
        geocoder.reverseGeocodeLocation(locations.first!, completionHandler: { placemark, error in
            guard let placemark = placemark?.first else { return }
            LocationManager.currentPlacemark = placemark
        })
    }
    
    func search(_ text: String) {
        if text == "" { searchResults = [MKLocalSearchCompletion](); searchCompletion(); return }
        searchCompleter.delegate = self
        searchCompleter.queryFragment = text
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results; searchCompletion()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) { print(error) }
    
    func searchResultToPlacemark(_ result: MKLocalSearchCompletion, completion: @escaping ((PlacemarkResult?) -> Void)) {
        let searchRequest = MKLocalSearchRequest(completion: result)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            guard let mapItem = response?.mapItems[safe: 0] else { completion(nil); return }
            completion((mapItem.placemark.coordinate.latitude, mapItem.placemark.coordinate.longitude, mapItem.name!, nil))
        }
    }
    
}
