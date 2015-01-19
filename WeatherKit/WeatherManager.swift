//
//  WeatherManager.swift
//  EduWeather
//
//  Created by Eduardo on 1/18/15.
//
//

import Foundation
import CoreLocation
import UIKit

protocol WeatherManagerDelegate {
    func weatherManager(weatherManager: WeatherManager, didChangeCurrentConditions conditions: Conditions?)
}

class WeatherManager : NSObject, CLLocationManagerDelegate {
    var delegate: WeatherManagerDelegate?

    private let queue = dispatch_queue_create("serial queue", DISPATCH_QUEUE_SERIAL)
    private var locationManager = CLLocationManager()
    private var currentConditions: Conditions? {
        didSet {
            if currentConditions != nil {
                let url = NSURL(string: "http://openweathermap.org/img/w/\(currentConditions!.iconName).png")
                currentConditions!.iconData = url == nil ? nil : NSData(contentsOfURL: url!)
            }
            self.delegate?.weatherManager(self, didChangeCurrentConditions: self.currentConditions)
        }
    }
    private var currentConditionsLocation: CLLocation?
    private let timer: Timer!
    
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        timer = Timer(interval: 60, queue: nil, repeats: true) {
            self.requestCurrentConditions()
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: nil) { notification in
            self.timer.start()
            self.locationManager.startUpdatingLocation()
            self.requestCurrentConditions()
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil, queue: nil) { notification in
            self.timer.stop()
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    private func requestConditions(urlPath: String) {
        ServerRequest(urlPath: urlPath, queue: queue) {
            self.currentConditions = Conditions(fromCurrentConditions: $0)
        }
    }
    
    private func requestCurrentConditions(coord: CLLocationCoordinate2D) {
        let urlPath = "http://api.openweathermap.org/data/2.5/weather?lat=\(coord.latitude)&lon=\(coord.longitude)"
        requestConditions(urlPath)
    }
    
    func requestCurrentConditions() {
        if locationManager.location != nil {
            requestCurrentConditions(locationManager.location.coordinate)
        }
    }
    
    func requestConditionsInCity(city: String) {
        let urlPath = "http://api.openweathermap.org/data/2.5/weather?q=\(city.stringByAddingUrlEncoding())"
        requestConditions(urlPath)
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .NotDetermined:
            manager.requestWhenInUseAuthorization()
        case .Authorized, .AuthorizedWhenInUse:
            manager.startUpdatingLocation()
        case .Denied:
            currentConditions = nil
        default:
            return
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let minDistance = 3000.0
        
        if currentConditionsLocation == nil || currentConditionsLocation!.distanceFromLocation(manager.location) > minDistance {
            requestCurrentConditions(manager.location.coordinate)
            currentConditionsLocation = manager.location
        }
    }
}

