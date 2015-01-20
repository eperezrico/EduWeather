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
        weather.automaticallyUpdateCurrentConditions = false // Stop auto-refresh while the user is entering the city

        openSearchTextField()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        weather.automaticallyUpdateCurrentConditions = true //Re-start automatic update of current conditions
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == cityTextField {
            
            if (weather.currentConditionsCustomCity == nil) != textField.text.isEmpty {
                cityLabel.text = textField.text
                conditions = nil
            }
            weather.currentConditionsCustomCity = textField.text.isEmpty ? nil : textField.text;
            updateConditions()
            closeSearchTextField()
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weather.delegate = self
    }
    
    func weather(weather: Weather, didChangeCurrentConditions conditions: Conditions?) {
        
        if conditions == nil {
            return
        }
        
        self.conditions = conditions
        updateConditions()
    }
    
    private func formattedTemp(kelvin: Float) -> String {
        return String(format: "%.1f", weather.temperatureUnit.fromKelvin(kelvin)) +  " " + weather.temperatureUnit.symbol
    }
    
    private func openSearchTextField() {
        cityTextField.text = nil
        cityTextField.hidden = false
        cityLabel.hidden = true
        cityTextField.becomeFirstResponder()
    }
    
    private func closeSearchTextField() {
        cityTextField.resignFirstResponder()
        cityTextField.hidden = true
        cityLabel.hidden = false
    }
    
    private func updateConditions() {
        cityLabel.hidden = false

        let hideDetails = conditions == nil
        tempLabel.hidden = hideDetails
        tempUnitLabel.hidden = hideDetails
        detailView.hidden = hideDetails
        iconImageView.hidden = hideDetails
        
        if conditions != nil {
            cityLabel.text = conditions!.city
            tempLabel.text = String(format: "%.0f", weather.temperatureUnit.fromKelvin(conditions!.temperature))
            tempUnitLabel.text = weather.temperatureUnit.symbol
            maxTempLabel.text = formattedTemp(conditions!.maxTemp)
            minTempLabel.text = formattedTemp(conditions!.minTemp)
            humidityLabel.text = "\(conditions!.humidity) %"
            pressureLabel.text = "\(conditions!.pressure) hpa"
            
            let iconData = conditions!.iconData
            iconImageView.image = iconData == nil ? nil : UIImage(data: iconData!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}

