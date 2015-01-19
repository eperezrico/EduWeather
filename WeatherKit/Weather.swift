//
//  Weather.swift
//  EduWeather
//
//  Created by Eduardo on 1/17/15.
//
//

import Foundation

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
}

public protocol WeatherDelegate {
    func weather(weather: Weather, didChangeCurrentConditions conditions: Conditions?)
}

public class Weather : WeatherManagerDelegate {
    public var temperatureUnit = TemperatureUnit.Fahrenheit
    public var delegate: WeatherDelegate?
    private let manager = WeatherManager()
    
    public init() {
        manager.delegate = self
    }
    
    public func requestCurrentConditions() {
        manager.requestCurrentConditions()
    }
    
    public func requestConditionsInCity(city: String) {
        manager.requestConditionsInCity(city)
    }
    
    func weatherManager(weatherManager: WeatherManager, didChangeCurrentConditions conditions: Conditions?) {
        dispatch_async(dispatch_get_main_queue()) {
            let delegate = self.delegate?
            delegate?.weather(self, didChangeCurrentConditions: conditions)
        }
    }

}

