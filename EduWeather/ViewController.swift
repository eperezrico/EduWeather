//
//  ViewController.swift
//  EduWeather
//
//  Created by Eduardo on 1/17/15.
//
//

import UIKit
import WeatherKit

class ViewController: UIViewController, WeatherDelegate, UITextFieldDelegate {
    
    let weather = Weather()
    var conditions: Conditions?
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var tempUnitLabel: UILabel!
    @IBOutlet weak var cityTextField: UITextField!
    
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var detailView: UIView!
    
    @IBAction func tapTemp(sender: AnyObject) {
        weather.temperatureUnit = weather.temperatureUnit == TemperatureUnit.Celsius ? TemperatureUnit.Fahrenheit : TemperatureUnit.Celsius
        updateConditions()
    }
    
    @IBAction func tapCity(sender: AnyObject) {
        cityTextField.text = nil
        cityTextField.hidden = false
        cityLabel.hidden = true
        cityTextField.becomeFirstResponder()
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == cityTextField {
            if textField.text.isEmpty {
                updateConditions()
                weather.requestCurrentConditions()
            } else {
                weather.requestConditionsInCity(textField.text)
            }
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weather.delegate = self
    }
    
    func weather(weather: Weather, didChangeCurrentConditions conditions: Conditions?) {
        
        if conditions == nil || cityTextField.isFirstResponder() {
            return
        }
        
        self.conditions = conditions
        updateConditions()
    }
    
    func formattedTemp(kelvin: Float) -> String {
        return String(format: "%.1f", weather.temperatureUnit.fromKelvin(kelvin)) +  " " + weather.temperatureUnit.symbol
    }
    
    func updateConditions() {
        
        cityLabel.hidden = false
        tempLabel.hidden = false
        tempUnitLabel.hidden = false
        detailView.hidden = false

        cityLabel.text = conditions!.city
        tempLabel.text = String(format: "%.0f", weather.temperatureUnit.fromKelvin(conditions!.temperature))
        tempUnitLabel.text = weather.temperatureUnit.symbol
        maxTempLabel.text = formattedTemp(conditions!.maxTemp)
        minTempLabel.text = formattedTemp(conditions!.minTemp)
        humidityLabel.text = "\(conditions!.humidity) %"
        pressureLabel.text = "\(conditions!.pressure) hpa"
        
        let iconData = conditions!.iconData
        iconImageView.image = iconData == nil ? nil : UIImage(data: iconData!)
        
        cityTextField.resignFirstResponder()
        cityTextField.hidden = true
        cityLabel.hidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}

