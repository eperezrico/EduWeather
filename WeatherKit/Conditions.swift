//
//  Conditions.swift
//  EduWeather
//
//  Created by Eduardo on 1/18/15.
//
//

import Foundation

public struct Conditions : DebugPrintable {
    public let temperature: Float
    public let minTemp: Float
    public let maxTemp: Float
    public let pressure: Float
    public let humidity: Float
    public let city: String
    public let iconName: String
    
    public var iconData: NSData?
    
    public var debugDescription: String {
        get {
            return "temperature: \(temperature)\nminTemp: \(minTemp)\nmaxTemp: \(maxTemp)\npressure: \(pressure)\nhumidity: \(humidity)"
        }
    }
    
    
    init?(fromCurrentConditions json: JSONObject?) {
        if !(json is NSDictionary) {
            return nil
        }
        
        let dic = json as NSDictionary
        
        let mainObj: AnyObject? = dic["main"]
        
        if !(mainObj is NSDictionary) {
            return nil
        }
        
        let main = mainObj as NSDictionary
        
        
        let temp: AnyObject? = main["temp"]
        
        if !(temp is NSNumber) {
            return nil
        }
        
        temperature = (temp as NSNumber).floatValue
        
        let minTemp: AnyObject? = main["temp_min"]
        
        if !(minTemp is NSNumber) {
            return nil
        }
        
        self.minTemp = (minTemp as NSNumber).floatValue
        
        let maxTemp: AnyObject? = main["temp_max"]
        
        if !(maxTemp is NSNumber) {
            return nil
        }
        
        self.maxTemp = (maxTemp as NSNumber).floatValue
        
        let pressure: AnyObject? = main["pressure"]
        if !(pressure is NSNumber) {
            return nil
        }
        
        self.pressure = (pressure as NSNumber).floatValue
        
        let humidity: AnyObject? = main["humidity"]
        
        if !(humidity is NSNumber) {
            return nil
        }
        
        self.humidity = (humidity as NSNumber).floatValue
        
        let sysObj: AnyObject? = dic["sys"]
        if !(sysObj is NSDictionary) {
            return nil
        }
        
        let countryObj: AnyObject? = (sysObj as NSDictionary)["country"]
        if !(countryObj is String) {
            return nil
        }
        
        let country = countryObj as String
        
        let city: AnyObject? = dic["name"]
        if !(city is String) {
            return nil
        }
        
        self.city = "\(city as String), \(country)"
        
        let weatherArray: AnyObject? = dic["weather"]
     
        if !(weatherArray is NSArray) {
            return nil
        }
        
        let weatherObj: AnyObject? = (weatherArray as NSArray).firstObject

        if !(weatherObj is NSDictionary) {
            return nil
        }

        let weather = weatherObj as NSDictionary
        
        let iconNamex: AnyObject? = weather["icon"]
        if !(iconNamex is NSString) {
            return nil
        }

        self.iconName = iconNamex as String
    }    
}
