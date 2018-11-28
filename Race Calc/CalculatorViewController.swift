//
//  CalculatorViewController.swift
//  Race Calc
//
//  Created by Brad Booysen on 6/11/18.
//  Copyright © 2018 Brad Booysen. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    let customColour = UIColor.getCustomRedColor()
    var raceInfo = RaceType()
    var totalTime = 0.0
    var hours = 0.0
    var minutes = 0.0
    var seconds = 0.0
    var totalDistance = 0.0
    var metricMeasure = true
    var selectedRaceDistance = RaceType()
    var racePace = 0.0
    
    @IBOutlet weak var splitsButton: UIButton!
    @IBOutlet weak var kilometerInput: UITextField!
    @IBOutlet weak var meterInput: UITextField!
    @IBOutlet weak var finishHour: UITextField!
    @IBOutlet weak var finishMinute: UITextField!
    @IBOutlet weak var finishSecond: UITextField!
    @IBOutlet weak var paceCalculation: UILabel!
    @IBOutlet weak var kmsOrMiles: UILabel!
    @IBOutlet weak var measureControl: UISegmentedControl!
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Set title
        title = raceInfo.title
        
        // Segmented control colour
        measureControl.tintColor = customColour
        
        // Set previous user measure preference
        let defaults = UserDefaults.standard
        let metricOrImperialPref = defaults.bool(forKey: "metricOrImperial")
        if metricOrImperialPref {
            metricMeasure = true
            measureControl.selectedSegmentIndex = 0
        } else {
            metricMeasure = false
            measureControl.selectedSegmentIndex = 1
        }
        // Prepopulate distances based on metric/imperial preference
        prepopulateDistances()
        
        self.hideKeyboardWhenTappedAround()
        
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
        prepopulateDistances()
        convertTime()
        calculateTime()
        convertDistance()
        displayPace()
    }
    
    // Calculate button tapped
    @IBAction func calculateButton(_ sender: Any) {
        convertTime()
        calculateTime()
        convertDistance()
        displayPace()
    }
    
    // Prepopulate distances based on user preference
    func prepopulateDistances() {
        if metricMeasure {
            
            switch raceInfo.title {
            case "Marathon":
                selectedRaceDistance.distance = 42.2
                kilometerInput.text = "42"
                meterInput.text = "2"
            case "Half Marathon":
                kilometerInput.text = "21"
                meterInput.text = "1"
                selectedRaceDistance.distance = 21.1
            case "10K":
                kilometerInput.text = "10"
                meterInput.text = "0"
                selectedRaceDistance.distance = 10
            case "5K":
                kilometerInput.text = "5"
                meterInput.text = "0"
                selectedRaceDistance.distance = 5
            default:
                kilometerInput.text = "0"
                meterInput.text = "0"
                selectedRaceDistance.distance = 0
            }
            kmsOrMiles.text = "Kms"
            
        } else {
            switch raceInfo.title {
            case "Marathon":
                kilometerInput.text = "26"
                meterInput.text = "2"
                selectedRaceDistance.distance = 26.2
            case "Half Marathon":
                kilometerInput.text = "13"
                meterInput.text = "1"
                selectedRaceDistance.distance = 13.1
            case "10K":
                kilometerInput.text = "6"
                meterInput.text = "0"
                selectedRaceDistance.distance = 6
            case "5K":
                kilometerInput.text = "3"
                meterInput.text = "0"
                selectedRaceDistance.distance = 3
            default:
                kilometerInput.text = "0"
                meterInput.text = "0"
                selectedRaceDistance.distance = 0
            }
            kmsOrMiles.text = "Miles"
        }
    }
    
    // Convert km/miles and mins/feet to single number
    func convertDistance() {
        if let kms = Double(kilometerInput.text!) {
            if let ms = Double(meterInput.text!) {
                let convertedDistance = kms + (ms / 10)
                totalDistance = convertedDistance
            }
        }
    }
    
    // Convert inputed time to seconds
    func convertTime() {
        if let hours1 = Double(finishHour.text!) {
            hours = (hours1*60)*60
        }
        if let minutes1 = Double(finishMinute.text!) {
            minutes = (minutes1 * 60)
        }
        if let seconds1 = Double(finishSecond.text!) {
            seconds = seconds1
        }
    }
    
    // Calculate total time in seconds
    func calculateTime () {
        let convertedTime = hours + minutes + seconds
        totalTime = convertedTime
    }
    
    // Calculate and display pace to user
    func displayPace() {
        let pace = (totalTime / totalDistance)
        if pace != 0 {
            racePace = pace
            if metricMeasure {
                paceCalculation.text = convertToTimeString(seconds: pace)! + " / km"
            } else {
                paceCalculation.text = convertToTimeString(seconds: pace)! + " / mile"
            }
        } else {
            paceCalculation.text = "^ Enter finish time above ^"
        }
    }
    
    // Save user preferences to UserDefaults when back button is pressed
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            saveData()
        }
    }
    
    // Save to UserDefaults
    func saveData() {
        let defaults = UserDefaults.standard
        defaults.set(metricMeasure, forKey: "metricOrImperial")
        defaults.set(hours, forKey: "hours")
        defaults.set(minutes, forKey: "minutes")
        defaults.set(seconds, forKey: "seconds")
    }
    
    
    // Send data to splits view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is SplitsTableViewController {
            let splitsVC = segue.destination as? SplitsTableViewController
            // Distance data
            splitsVC?.distance = selectedRaceDistance
            // Pace data
            splitsVC?.pace = racePace
            // Metric or Imperial data
            splitsVC?.metricMeasure = metricMeasure
            
        }
    }
    
    // Format pace
    func convertToTimeString (seconds: Double) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [ .minute, .second ]
        formatter.zeroFormattingBehavior = [ .pad ]
        let formattedDuration = formatter.string(from: seconds)
        return formattedDuration
    }
}



