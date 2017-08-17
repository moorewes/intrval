//
//  IntervalDetailTableViewController.swift
//  Interval
//
//  Created by Wesley Moore on 8/1/17.
//  Copyright © 2017 Wes Moore. All rights reserved.
//

import UIKit

class IntervalDetailTableViewController: UITableViewController, UITextFieldDelegate {
    
    struct SegueID {
        private init() {}
        static let editDate = "editDate"
        static let editTime = "editTime"
        static let showAllReminders = "showAllReminders"
        static let chooseReminderType = "chooseReminderType"
        static let showReminderDetail = "showReminderDetail"
    }
    
    var interval: Interval!
    var index: Int!
    
    var isFullyLoaded = false

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var alertCountLabel: UILabel!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshUI()
        title = "Edit Counter"
        tableView.tableFooterView = UIView()
        
//        let navTitleColor = UIColor.white // Themes.current.navTitleColor
//        let navBarFont = Theme.navigationBarFont
//        navigationController?.navigationBar.titleTextAttributes = [
//            NSForegroundColorAttributeName: navTitleColor,
//            NSFontAttributeName: navBarFont
//        ]
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.setTitleTextAttributes([NSFontAttributeName: Theme.navigationBarFont], for: .normal)
        navigationItem.backBarButtonItem = backItem
        
//        navigationItem.backBarButtonItem = UIBarButtonItem()
//        navigationItem.backBarButtonItem?.title = "Back"
//        navigationItem.backBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: Theme.navigationBarFont], for: .normal)
        //navigationItem.backBarButtonItem?.tintColor = UIColor.white
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFullyLoaded {
            refreshUI()
        }
        if interval.description.isEmpty {
            titleTextField.becomeFirstResponder()
        }
        isFullyLoaded = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if titleTextField.isFirstResponder {
            commitTitleEdits()
            titleTextField.resignFirstResponder()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dateVC = segue.destination as? EditDateViewController {
            dateVC.interval = interval
        } else if let timeVC = segue.destination as? EditTimeViewController {
            timeVC.interval = interval
        } else if let remindersListVC = segue.destination as? RemindersListTableViewController {
            remindersListVC.interval = interval
        }
        if titleTextField.isFirstResponder {
            commitTitleEdits()
            titleTextField.resignFirstResponder()
        }
    }

    
    // MARK: - UITextFieldDelegate
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commitTitleEdits()
        textField.resignFirstResponder()
        return true
    }
    
    func commitTitleEdits() {
        interval.description = titleTextField.text!
        saveInterval()
    }
    
    // MARK: - Convenience
    
    func refreshUI() {
        titleTextField.text = interval.description
        dateLabel.text = interval.dateString
        timeLabel.text = interval.includeTime ? interval.timeString : "Not Set"
        let remindersCount = RemindersDataManager.main.reminders(forIntervalCreationDate: interval.creationDate).count
        if remindersCount > 0 {
            alertCountLabel.text = "\(remindersCount)"
        } else {
            alertCountLabel.text = "None"
        }
    }
    
    func saveInterval() {
        DataManager.main.update(interval: interval)
    }
    
    
    

}
