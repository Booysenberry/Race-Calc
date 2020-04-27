//
//  SplitsTableViewController.swift
//  Race Calc
//
//  Created by Brad Booysen on 22/11/18.
//  Copyright © 2018 Brad Booysen. All rights reserved.
//

import UIKit

class SplitsTableViewController: UITableViewController {
    
    var markers = [Float]()
    var splits = [Float]()
    var pace: Float = 0.0
    var distance: Float = 0.0
    var metricMeasure = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        title = "Your Splits"
        
        divideDistanceIntoSplits()
        calculateSplits()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return markers.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "splitsCell") as! CustomCell
        
        let marker = markers[indexPath.row]
        let split = splits[indexPath.row]
        
        if metricMeasure == true {
            let distance = Measurement(value: Double(marker), unit: UnitLength.kilometers)
            let formattedDistance = measurementFormatter.string(from: distance)
            cell.distanceLabel.text = "\(formattedDistance)"
        } else {
            let distance = Measurement(value: Double(marker), unit: UnitLength.miles)
            let formattedDistance = measurementFormatter.string(from: distance)
            cell.distanceLabel.text = "\(formattedDistance)"
        }
        
        cell.paceLabel.text = convertToTimeString(seconds: Double(split))
        
        return cell
    }
    
    // Calculate distance markers
    func divideDistanceIntoSplits()  {
        
        var distanceMarkers: Float = 0.0
        var divider: Float = 1000
        
        if metricMeasure {
            divider = 1000
        } else {
            divider = 1609
        }
        
        while distanceMarkers <= (distance / divider) - 1 {
            markers.append(distanceMarkers + 1)
            distanceMarkers += 1
        }
        let remainingDistance = distance.remainder(dividingBy: 1)
        if remainingDistance != 0 {
            markers.append(distance.rounded() + remainingDistance)
        } else {
        }
        
    }
    
    // Calculate splits for each km/mile
    func calculateSplits() {
        for split in markers {
            let speed = split * pace
            splits.append(speed)
        }
    }
    
    // Format time
    func convertToTimeString (seconds: Double) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [ .hour, .minute, .second ]
        formatter.zeroFormattingBehavior = [ .default ]
        let formattedDuration = formatter.string(from: seconds)
        return formattedDuration
    }
    
    // Format distance
    let measurementFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumIntegerDigits = 1
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 1
        formatter.numberFormatter = numberFormatter
        
        return formatter
    }()
    
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
    }
}


