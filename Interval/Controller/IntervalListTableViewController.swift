//
//  IntervalListTableViewController.swift
//  Interval
//
//  Created by Wesley Moore on 8/1/17.
//  Copyright © 2017 Wes Moore. All rights reserved.
//

import UIKit

struct Theme {
    static let navigationBarFont = UIFont(name: "Futura-CondensedMedium", size: 22) ?? UIFont.systemFont(ofSize: 18)
    //static let intrvalGreen = UIColor(colorLiteralRed: 36/255, green: 138/255, blue: 174/255, alpha: 1)
    static let intrvalGreen = UIColor(red: 36/255, green: 138/255, blue: 174/255, alpha: 1)
}

class IntervalListTableViewController: UITableViewController {
    
    private struct SegueID {
        static let Edit = "editInterval"
    }
    
    var intervals = [Interval]()
    var selectedInterval: Interval?
    var startupSyncComplete = false
    
    @IBOutlet weak var helpBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var newIntervalButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        newIntervalButton.layer.cornerRadius = newIntervalButton.frame.height/2
        
        navigationItem.rightBarButtonItem = editButtonItem
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshData()
        if !startupSyncComplete {
            DataManager.main.transferDataToWatch()
            startupSyncComplete = true
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? IntervalDetailTableViewController {
            if let existingInterval = selectedInterval {
                vc.interval = existingInterval
                selectedInterval = nil
            } else {
                let newDate = Date().withTime(hour: 0, minute: 0)
                let newInterval = Interval(date: newDate, unit: .day, includeTime: false, description: "", creationDate: Date())
                DataManager.main.store(interval: newInterval)
                vc.interval = newInterval
                vc.isNewInterval = true
            }
            
        }
    }
    
    // MARK: - Convenience
    
    func refreshData() {
        DataManager.main.clearAccidentIntervals()
        intervals = DataManager.main.allIntervals()
        tableView.reloadData()
    }

}

extension IntervalListTableViewController {
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return intervals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: IntervalTableViewCell.id, for: indexPath) as! IntervalTableViewCell
        cell.interval = intervals[indexPath.row]
        print(cell.interval.date.localeDescription)
        cell.refreshUI()
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! IntervalTableViewCell
        let interval = cell.interval
        selectedInterval = interval
        performSegue(withIdentifier: SegueID.Edit, sender: nil)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let cell = tableView.cellForRow(at: indexPath) as! IntervalTableViewCell
            let interval = cell.interval!
            DataManager.main.remove(interval: interval)
            refreshData()
        }
    }
}
