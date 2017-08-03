//
//  RemindersChooseTypeTableViewController.swift
//  Interval
//
//  Created by Wesley Moore on 8/3/17.
//  Copyright © 2017 Wes Moore. All rights reserved.
//

import UIKit

class RemindersChooseTypeTableViewController: UITableViewController {
    
    struct SegueID {
        private init() {}
        static let months = "Months"
        static let weeks = "Weeks"
        static let days = "Days"
        static let hours = "Hours"
        static let minutes = "Minutes"
        static let custom = "Custom"
        static let completion = "Completion"
    }
    
    var interval: Interval!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }


    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let setConstantVC = segue.destination as? RemindersSetPeriodConstantViewController {
            switch segue.identifier! {
            case SegueID.months: setConstantVC.unit = .month
            case SegueID.weeks: setConstantVC.unit = .weekOfYear
            case SegueID.days: setConstantVC.unit = .day
            case SegueID.hours: setConstantVC.unit = .hour
            case SegueID.minutes: setConstantVC.unit = .minute
            default: break
            }
            setConstantVC.interval = interval
        }
        
    }
    

}
