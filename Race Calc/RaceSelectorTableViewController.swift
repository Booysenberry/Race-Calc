//
//  CalculatorViewController.swift
//  Race Calc
//
//  Created by Brad Booysen on 6/11/18.
//  Copyright © 2018 Brad Booysen. All rights reserved.
//

import UIKit

class RaceSelectorTableViewController: UITableViewController {
    
    // Create an empty array of 'RaceType' objects
    var races = [RaceType]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Select Distance"
        
        // Selection of race distances
        let race1 = RaceType()
        race1.title = "Marathon"
        let race2 = RaceType()
        race2.title = "Half Marathon"
        let race3 = RaceType()
        race3.title = "10K"
        let race4 = RaceType()
        race4.title = "5K"
        
        races = [race1,race2,race3,race4]
        
    }
    
    // Set number of rows equal to number of race distances
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return races.count
    }
    
    // Set cell content to the name of each race distance
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        let selectedRace = races[indexPath.row].title
        cell.textLabel?.text = selectedRace
        return cell
    }
    
    // Move to calculator view controller when user taps a table cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedRace = races[indexPath.row]
        performSegue(withIdentifier: "moveToCalculator", sender: selectedRace)
        
    }
    
    // Pass on data to the calculator view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let calculatorVC = segue.destination as? CalculatorViewController {
            if let selectedRace = sender as? RaceType{
                calculatorVC.raceInfo = selectedRace
            }
        }
    }
}


