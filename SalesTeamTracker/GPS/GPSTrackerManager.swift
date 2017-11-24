//
//  GPSTrackerManager.swift
//  Mobilizer
//
//  Created by Selva's MacBook Pro on 08/02/17.
//  Copyright © 2017 EphronTach LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import AFNetworking
import UserNotifications

class GPSTrackerManager: NSObject, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    var seenError : Bool = false
    
    func startTracking() {
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus){
        if status != CLAuthorizationStatus.notDetermined {
            // iOS 10 support
            if #available(iOS 10, *) {
                UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
                let application:UIApplication = UIApplication.shared
                application.registerForRemoteNotifications()
            }
                // iOS 9 support
            else {
                UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        let coord = locationObj.coordinate
        
        let latitude:String = String(format: "%f", coord.latitude)
        UserDefaults.standard.set(latitude, forKey: "Latitude")
        let longitude:String = String(format: "%f", coord.longitude)
        UserDefaults.standard.set(longitude, forKey: "Longitude")
        
    }
    
    func getLatitude()->String{
        var sReturnString:String = ""
        if let sLat:String = UserDefaults.standard.value(forKey: "Latitude") as? String{
            sReturnString = sLat
        }
        return sReturnString
    }
    
    func getLongitude()->String{
        var sReturnString:String = ""
        if let sLong:String = UserDefaults.standard.value(forKey: "Longitude") as? String{
            sReturnString = sLong
        }
        return sReturnString
    }
    
}
