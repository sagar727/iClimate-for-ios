//
//  LocationService.swift
//  iClimate
//
//  Created by Sagar Modi on 17/01/2024.
//

import Foundation
import CoreLocation
import Observation

@Observable
final class LocationService: NSObject, CLLocationManagerDelegate {
    var manager = CLLocationManager()
    
    var latitude: Double{
        manager.location?.coordinate.latitude ?? 37.322998
    }
    var longitude: Double{
        manager.location?.coordinate.longitude ?? -122.032181
    }
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
