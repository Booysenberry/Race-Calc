//
//  CalculatorViewController.swift
//  Race Calc
//
//  Created by Brad Booysen on 6/11/18.
//  Copyright © 2018 Brad Booysen. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController, UITextFieldDelegate {
    
    let customColour = UIColor.getCustomRedColor()
    var raceInfo = RaceType()
    var totalTime = 0.0
    var hours = 0.0
    var minutes = 0.0
    var seconds = 0.0
    var totalDistance = 0.0
    var metricMeasure = true
    var selectedRaceDistance = RaceType()
    var racePace: Float = 0.0
    var customDistance = RaceType()
    
    
    
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var splitsButton: UIButton!
    @IBOutlet weak var kilometerInput: UITextField!
    @IBOutlet weak var meterInput: UITextField!
    @IBOutlet weak var finishHour: UITextField!
    @IBOutlet weak var finishMinute: UITextField!
    @IBOutlet weak var finishSecond: UITextField!
    @IBOutlet weak var paceCalculation: UILabel!
    @IBOutlet weak var kmsOrMiles: UILabel!
    @IBOutlet weak var measureControl: UISegmentedControl!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var paceSlider: UISlider!
    @IBOutlet weak var distanceSelector: UISegmentedControl!
    
    let measurementFormatter = MeasurementFormatter()
    let numberFormatter = NumberFormatter()
    let defaults = UserDefaults.standard
    let locale = Locale.current
    
    
    override func viewDidLoad() {
        
        // Set title
        title = "Race Calculator"
        
        metricMeasure = locale.usesMetricSystem
        
        // Segmented control colour
        measureControl.tintColor = customColour
        
        switch distanceSelector.selectedSegmentIndex {
        case 0:
            raceInfo.distance = 5000
            timeSlider.minimumValue = 900
            timeSlider.maximumValue = 3600
        case 1:
            raceInfo.distance = 10000
            timeSlider.minimumValue = 1800
            timeSlider.maximumValue = 7200
        case 2:
            raceInfo.distance = 21100
            timeSlider.minimumValue = 3600
            timeSlider.maximumValue = 14400
        case 3:
            raceInfo.distance = 42200
            timeSlider.minimumValue = 7200
            timeSlider.maximumValue = 30390
        default:
            break
        }
        
        setValues()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    // Set distance and measurement units based on user locale
    func setValues() {
        
        let distance = Measurement(value: Double(raceInfo.distance), unit: UnitLength.meters)
        
        switch metricMeasure {
        case true:
            measureControl.selectedSegmentIndex = 0
            measurementFormatter.locale = Locale(identifier: "EN_NZ")
            paceLabel.text = "\(paceString(time: TimeInterval(paceSlider.value))) /km"
            distanceLabel.text = measurementFormatter.string(from: distance)
            
        default:
            measureControl.selectedSegmentIndex = 1
            paceLabel.text = "\(paceString(time: TimeInterval(paceSlider.value))) /mile"
            measurementFormatter.locale = Locale(identifier: "EN_US")
            numberFormatter.maximumFractionDigits = 1
            measurementFormatter.numberFormatter = numberFormatter
            distanceLabel.text = measurementFormatter.string(from: distance)
        }
        timeLabel.text = "\(timeString(time: TimeInterval(timeSlider.value)))"
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
    
    
    
    @IBAction func distanceChanged(_ sender: Any) {
        
        switch distanceSelector.selectedSegmentIndex {
        case 0:
            raceInfo.distance = 5000
            timeSlider.minimumValue = 900
            timeSlider.maximumValue = 3600
            
        case 1:
            raceInfo.distance = 10000
            timeSlider.minimumValue = 1800
            timeSlider.maximumValue = 7200
        case 2:
            raceInfo.distance = 21100
            timeSlider.minimumValue = 3600
            timeSlider.maximumValue = 14400
        case 3:
            raceInfo.distance = 42200
            timeSlider.minimumValue = 7200
            timeSlider.maximumValue = 30390
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
//        setValues()
        paceSliderChanged(paceSlider)
    }
    
    @IBAction func timeSliderChanged(_ sender: UISlider) {
        
        timeLabel.text = "\(timeString(time: TimeInterval(sender.value)))"
        let time = sender.value / (raceInfo.distance / 1000)
        paceSlider.value = time
        
        if metricMeasure {
            paceLabel.text = "\(paceString(time: TimeInterval(sender.value))) /km"
        } else {
            paceLabel.text = "\(paceString(time: TimeInterval(sender.value))) /mile"
        }
    }
    
    @IBAction func paceSliderChanged(_ sender: UISlider) {
        
        if metricMeasure {
            let time = sender.value.rounded(.down) * (raceInfo.distance / 1000)
            timeLabel.text = "\(timeString(time: TimeInterval(time)))"
            timeSlider.value = time
            paceLabel.text = "\(paceString(time: TimeInterval(sender.value))) /km"
        } else {
            let time = sender.value.rounded(.down) * (raceInfo.distance / 1609)
            timeLabel.text = "\(timeString(time: TimeInterval(time)))"
            timeSlider.value = time
            paceLabel.text = "\(paceString(time: TimeInterval(sender.value))) /mile"
        }
        racePace = paceSlider.value
    }
    
    
    // Send data to splits view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is SplitsTableViewController {
            let splitsVC = segue.destination as? SplitsTableViewController
            // Distance data
            splitsVC?.distance = totalDistance
            // Pace data
            splitsVC?.pace = Double(racePace)
            // Metric or Imperial data
            splitsVC?.metricMeasure = metricMeasure
            
        }
    }
    
    // Format pace
    func convertToTimeString (seconds: Double) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        let formattedDuration = formatter.string(from: seconds)
        return formattedDuration
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 2
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}



