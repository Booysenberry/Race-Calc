//
//  CalculatorViewController.swift
//  Race Calc
//
//  Created by Brad Booysen on 6/11/18.
//  Copyright © 2018 Brad Booysen. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController, UITextFieldDelegate {
    
    var raceInfo = RaceType()
    var metricMeasure = true
    var minimumSliderValue: Float = 0.0
    var maximumSliderValue: Float = 0.0
    
    @IBOutlet weak var measureControl: UISegmentedControl!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var paceSlider: UISlider!
    @IBOutlet weak var distanceSelector: UISegmentedControl!
    
    let customColour = UIColor.getCustomRedColor()
    let measurementFormatter = MeasurementFormatter()
    let numberFormatter = NumberFormatter()
    let defaults = UserDefaults.standard
    let locale = Locale.current
    let fiveSecondIncrements: Float = 5
    let thirtySecondIncrements: Float = 30
    
    override func viewDidLoad() {
        
        raceInfo.distance = 5000
        
        // Set title
        title = "Race Calculator"
        
        // Style sliders
        for slider in [paceSlider, timeSlider] {
            slider?.minimumTrackTintColor = UIColor.getCustomRedColor()
            slider?.thumbTintColor = UIColor.getCustomRedColor()
        }
        
        // Set unit preference
        metricMeasure = locale.usesMetricSystem
        
        // Segmented control colour
        measureControl.tintColor = customColour
        
        setValues()
        
        // Add long press gesture recogniser to distance label
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(sender:)))
        distanceLabel.addGestureRecognizer(longPress)
        distanceLabel.isUserInteractionEnabled = true
        
        self.hideKeyboardWhenTappedAround()
    }
    
    // Set distance and measurement units based on user locale
    func setValues() {
        
        let distance = Measurement(value: Double(raceInfo.distance), unit: UnitLength.meters)
        distanceLabel.font = distanceLabel.font.withSize(25)
        
        let timeValues = calculateMinAndMaxTimes(slowestPace: 12, fastestPace: 3)
        
        timeSlider.minimumValue = timeValues.0 // seconds
        timeSlider.maximumValue = timeValues.1 // seconds
        
        switch metricMeasure {
        case true:
            
            if raceInfo.distance != 0 {
                
                // Metric format
                measureControl.selectedSegmentIndex = 0
                measurementFormatter.locale = Locale(identifier: "EN_NZ")
                distanceLabel.text = measurementFormatter.string(from: distance)
                
                // Set min and max slider values
                paceSlider.minimumValue = (3 * 60) // seconds
                paceSlider.maximumValue = (12 * 60) // seconds
                paceLabel.text = "\(paceString(time: TimeInterval(paceSlider.value))) /km"
                
            } else {
                distanceLabel.text = "Long press here to enter distance"
                distanceLabel.font = distanceLabel.font.withSize(17)
            }
            
        default:
            
            if raceInfo.distance != 0 {
                
                // Imperial format
                measureControl.selectedSegmentIndex = 1
                measurementFormatter.locale = Locale(identifier: "EN_US")
                numberFormatter.maximumFractionDigits = 1
                measurementFormatter.numberFormatter = numberFormatter
                distanceLabel.text = measurementFormatter.string(from: distance)
                
                // Set min and max slider values
                paceSlider.minimumValue = (4.8 * 60) // mins per mile pace
                paceSlider.maximumValue = (20 * 60) // mins per mile pace
                paceLabel.text = "\(paceString(time: TimeInterval(paceSlider.value))) /mile"
                
            } else {
                distanceLabel.text = "Long press here to enter distance"
                distanceLabel.font = distanceLabel.font.withSize(17)
            }
        }
        paceSliderChanged(paceSlider)
        timeLabel.text = "\(timeString(time: TimeInterval(timeSlider.value)))"
    }
    
    
    // Calculate min and max times and set time slider values
    func calculateMinAndMaxTimes(slowestPace: Float, fastestPace: Float) -> (Float, Float) {
        
        var minimumTime: Float = 0.0
        var maximumTime: Float = 0.0
        
        if metricMeasure {
            
            // Calculate min and max time values
            minimumTime = raceInfo.distance / (16.6666667 / fastestPace)
            maximumTime = raceInfo.distance / (16.6666667 / slowestPace)
        } else {
            
            // Calculate min and max time values
            minimumTime = raceInfo.distance / (26.8224 / (fastestPace * 1.6))
            maximumTime = raceInfo.distance / (26.8224 / (slowestPace * 1.6))
        }
        return (minimumTime, maximumTime)
    }
    
    @IBAction func distanceChanged(_ sender: Any) {
        
        switch distanceSelector.selectedSegmentIndex {
        case 0:
            raceInfo.distance = 5000
        case 1:
            raceInfo.distance = 10000
        case 2:
            raceInfo.distance = 21100
        case 3:
            raceInfo.distance = 42200
        case 4:
            raceInfo.distance = 0
        default:
            break
        }
        setValues()
        paceSliderChanged(paceSlider)
    }
    
    // Allow user to change between metric and imperial measurements
    @IBAction func measureChanged(_ sender: Any) {
        switch measureControl.selectedSegmentIndex {
        case 0:
            metricMeasure = true
        case 1:
            metricMeasure = false
        default:
            break
        }
        setValues()
        paceSliderChanged(paceSlider)
    }
    
    @IBAction func timeSliderChanged(_ sender: UISlider) {
        
        // Adjust time in 30 second increments
        let roundedTime = round(timeSlider.value / thirtySecondIncrements) * thirtySecondIncrements
        timeSlider.value = roundedTime
        
        timeLabel.text = "\(timeString(time: TimeInterval(sender.value)))"
        
        if metricMeasure {
            let speed = sender.value / (raceInfo.distance / 1000)
            paceSlider.value = speed
            paceLabel.text = "\(paceString(time: TimeInterval(speed))) /km"
        } else {
            let speed = sender.value / (raceInfo.distance / 1609)
            paceSlider.value = speed
            paceLabel.text = "\(paceString(time: TimeInterval(speed))) /mile"
        }
    }
    
    @IBAction func paceSliderChanged(_ sender: UISlider) {
        
        // Adjust pace in 5 second increments
        let roundedPace = round(paceSlider.value / fiveSecondIncrements) * fiveSecondIncrements
        paceSlider.value = roundedPace
        
        if metricMeasure {
            let time = sender.value * (raceInfo.distance / 1000)
            timeLabel.text = "\(timeString(time: TimeInterval(time)))"
            timeSlider.value = sender.value * (raceInfo.distance / 1000)
            paceLabel.text = "\(paceString(time: TimeInterval(sender.value))) /km"
            
        } else {
            
            let time = sender.value * (raceInfo.distance / 1609)
            timeLabel.text = "\(timeString(time: TimeInterval(time)))"
            timeSlider.value = sender.value * (raceInfo.distance / 1609)
            paceLabel.text = "\(paceString(time: TimeInterval(sender.value))) /mile"
        }
    }
    
    // Send data to splits view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is SplitsTableViewController {
            let splitsVC = segue.destination as? SplitsTableViewController
            // Distance data
            splitsVC?.distance = raceInfo.distance
            // Pace data
            splitsVC?.pace = paceSlider.value
            // Metric or Imperial data
            splitsVC?.metricMeasure = metricMeasure
        }
    }
    
    // Format time string
    func timeString(time: TimeInterval) -> String {
        
        let hour = Int(time) / 3600
        let minute = Int(time) / 60 % 60
        let second = Int(time) % 60
        
        // return formated string
        return String(format: "%02i:%02i:%02i", hour, minute, second)
    }
    
    // Format pace string
    func paceString(time: TimeInterval) -> String {
        
        let minute = Int(time) / 60 % 60
        let second = Int(time) % 60
        
        // return formated string
        return String(format: "%02i:%02i", minute, second)
    }
    
    // Allows the user to change distance if long pressing on distance label
    @objc func longPress(sender: UILongPressGestureRecognizer) {
        
        let alert = UIAlertController(title: "Change Distance", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in
            textField.autocapitalizationType = .words
            textField.keyboardType = .decimalPad
            
            
            if self.metricMeasure {
                textField.placeholder = "kilometers"
            } else {
                textField.placeholder = "miles"
            }
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            if let distanceString = alert.textFields?.first?.text {
                if let convertedDistance = Float(distanceString) {
                    if distanceString != "" {
                        
                        if self.metricMeasure {
                            self.raceInfo.distance = (convertedDistance * 1000)
                        } else {
                        self.raceInfo.distance = (convertedDistance * 1609)
                        }
                        self.setValues()
                    }
                }
            }
        }))
        self.present(alert, animated: true)
    }
}



