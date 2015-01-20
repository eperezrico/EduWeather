//
//  Weather.swift
//  EduWeather
//
//  Created by Eduardo on 1/18/15.
//
//

import Foundation
import CoreLocation
import UIKit

public enum TemperatureUnit {
    case Celsius, Fahrenheit
    
    public func fromKelvin(kelvin: Float) -> Float {
        let celsius = kelvin - 273.15
        switch self {
        case .Celsius:
            return celsius
        case .Fahrenheit:
            return celsius*1.8 + 32
        }
    }
    
    public var symbol: String {
        get {
            switch self {
            case .Celsius:
                return "℃"
            case .Fahrenheit:
                return "℉"
            }
        }
    }
    
    var identifier: String {
        get {
            switch self {
            case .Celsius:
                return "celsius"
            case .Fahrenheit:
                return "fahrenheit"
            }
        }
    }
    
    static func fromIdentifier(identifier: String?) -> TemperatureUnit {
        let defaultUnit = TemperatureUnit.Fahrenheit
        if identifier == nil {
            return defaultUnit
        }
        
        switch identifier! {
        case TemperatureUnit.Celsius.identifier:
            return .Celsius
        case TemperatureUnit.Fahrenheit.identifier:
            return .Fahrenheit
        default:
            return defaultUnit
        }
    }
}


public protocol WeatherDelegate {
    func weather(weather: Weather, didChangeCurrentConditions conditions: Conditions?)
}

public class Weather {
    private let currentConditionsCustomCityKey = "currentConditionsCustomCity"
    private let tempUnitKey = "tempUnitKey"
    
    public var delegate: WeatherDelegate?
    
    public var automaticallyUpdateCurrentConditions: Bool = true {
        didSet {
            updateAutomaticBehavior()
        }
    }
    
    public var currentConditionsCustomCity: String? {
        didSet {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(currentConditionsCustomCity, forKey: currentConditionsCustomCityKey)
            userDefaults.synchronize()
            requestCurrentConditions()
        }
    }
    
    public var temperatureUnit: TemperatureUnit {
        didSet {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(temperatureUnit.identifier, forKey: tempUnitKey)
            userDefaults.synchronize()
        }
    }

    private let queue = dispatch_queue_create("serial queue", DISPATCH_QUEUE_SERIAL)
    private var locationManager = CLLocationManager()
    private var currentConditions: Conditions? {
        didSet {
            if currentConditions != nil {
                let url = NSURL(string: "http://openweathermap.org/img/w/\(currentConditions!.iconName).png")
                currentConditions!.iconData = url == nil ? nil : NSData(contentsOfURL: url!)
            }
            dispatch_async(dispatch_get_main_queue()) {
                let delegate = self.delegate?
                delegate?.weather(self, didChangeCurrentConditions: self.currentConditions)
            }
        }
    }
    private var currentConditionsLocation: CLLocation?
    private let timer: Timer!
    private let locationManagerDelegate = LocationManagerDelegate()
    
    public init() {
        let city: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey(currentConditionsCustomCityKey)
        currentConditionsCustomCity = city as? String
        let unit = NSUserDefaults.standardUserDefaults().objectForKey(tempUnitKey) as? String
        temperatureUnit = TemperatureUnit.fromIdentifier(unit)

        locationManagerDelegate.weather = self

        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.startUpdatingLocation()
        locationManager.delegate = locationManagerDelegate
        
        timer = Timer(interval: 60, queue: nil, repeats: true) {
            self.requestCurrentConditions()
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: nil) { notification in
            self.updateAutomaticBehavior()
            self.requestCurrentConditions()
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil, queue: nil) { notification in
            self.updateAutomaticBehavior()
        }
    }
    
    private func updateAutomaticBehavior() {
        let isAppActive = UIApplication.sharedApplication().applicationState == UIApplicationState.Active
        
        if automaticallyUpdateCurrentConditions && isAppActive {
            timer.start()
            locationManager.startUpdatingLocation()
        } else {
            timer.stop()
            locationManager.stopUpdatingLocation()
        }
    }
    
    private func requestConditions(urlPath: String) {
        ServerRequest(urlPath: urlPath, queue: queue) {
            self.currentConditions = Conditions(fromCurrentConditions: $0)
        }
    }
    
    private func requestCurrentLocalConditions(coord: CLLocationCoordinate2D) {
        let urlPath = "http://api.openweathermap.org/data/2.5/weather?lat=\(coord.latitude)&lon=\(coord.longitude)"
        requestConditions(urlPath)
    }
    
    private func requestCurrentConditions() {
        if (currentConditionsCustomCity != nil) {
            requestCurrentConditionsInCity(currentConditionsCustomCity!)
        } else if locationManager.location != nil {
            requestCurrentLocalConditions(locationManager.location.coordinate)
        }
    }
    
    // Creating a private delegate avoid declaring Weather as NSObject, CLLocationManagerDelegate (this is an implementation detail and should't be exposed as public)
    private class LocationManagerDelegate : NSObject, CLLocationManagerDelegate {
        var weather: Weather?
        
        func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            switch status {
            case .NotDetermined:
                manager.requestWhenInUseAuthorization()
            case .Authorized, .AuthorizedWhenInUse:
                manager.startUpdatingLocation()
            case .Denied:
                weather?.currentConditions = nil
            default:
                return
            }
        }
        
        func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
            let minDistance = 3000.0
            if weather?.currentConditionsLocation == nil || weather?.currentConditionsLocation!.distanceFromLocation(manager.location) > minDistance {
                weather?.currentConditionsLocation = manager.location
                weather?.requestCurrentConditions()
            }
        }
    }
    
    private func requestCurrentConditionsInCity(city: String) {
        let urlPath = "http://api.openweathermap.org/data/2.5/weather?q=\(city.stringByAddingUrlEncoding())"
        requestConditions(urlPath)
    }
}

