//
//  LocationManager.swift
//  Mesh
//
//  Created by Christopher Truman on 8/18/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class LocationManager : NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
    
    static var currentLocation : CLLocation?
    
    let manager = CLLocationManager()
    static var locationUpdate : ((CLLocation) -> Void)? = nil

    static func startTracking() {// -> (enabled: Bool, status: CLAuthorizationStatus) {
        shared.manager.delegate = shared
        shared.manager.distanceFilter = 10
        shared.manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        if CLLocationManager.locationServicesEnabled() {
            shared.manager.startMonitoringSignificantLocationChanges()
            shared.manager.requestLocation()
        }
        if CLLocationManager.authorizationStatus() == .notDetermined {
            shared.manager.requestWhenInUseAuthorization()
        }
        //return (CLLocationManager.locationServicesEnabled(), CLLocationManager.authorizationStatus())
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch (status) {
        case .authorizedWhenInUse:
            manager.startMonitoringSignificantLocationChanges()
            break
        case .restricted, .denied:
            let alertController = UIAlertController(
                title: "Location Access Disabled",
                message: "In order to match you with nearby users & events, please open this app's settings and set location access to 'When in use'.",
                preferredStyle: .alert)
            
            let openAction = UIAlertAction("Open Settings") { (action) in
                guard let url = URL(string:UIApplicationOpenSettingsURLString) else { return }
                UIApplication.shared.openURL(url as URL)
            }
            alertController.addActions(UIAlertAction.cancel(), openAction)
            
            UIApplication.shared.keyWindow!.rootViewController!.present(alertController)
            break
        default: break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) { print(error) }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        LocationManager.currentLocation = locations.first!
        LocationManager.locationUpdate?(locations.first!)
    }
}
