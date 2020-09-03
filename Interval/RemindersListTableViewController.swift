////
////  RemindersListTableViewController.swift
////  Interval
////
////  Created by Wesley Moore on 8/3/17.
////  Copyright © 2017 Wes Moore. All rights reserved.
////
//
//import UIKit
//
//class RemindersListTableViewController: UITableViewController {
//    
//    struct SegueID {
//        static let editReminder = "editReminder"
//        static let newReminder = "newReminder"
//    }
//    
//    var interval: Interval!
//    var reminders: [Reminder] = []
//    var selectedReminder: Reminder?
//    var shouldSaveOnReturn = false
//    
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        refreshData()
//        
//        let backItem = UIBarButtonItem()
//        backItem.title = "Back"
//        backItem.setTitleTextAttributes(convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): Theme.navigationBarFont]), for: .normal)
//        navigationItem.backBarButtonItem = backItem
//        // Uncomment the following line to preserve selection between presentations
//        // self.clearsSelectionOnViewWillAppear = false
//        
//        editButtonItem.setTitleTextAttributes(convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): Theme.navigationBarFont]), for: .normal)
//        editButtonItem.tintColor = UIColor.white
//        navigationItem.rightBarButtonItem = editButtonItem
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        if shouldSaveOnReturn {
//            refreshData()
//            RemindersDataManager.main.save()
//            shouldSaveOnReturn = false
//        }
//        
//    }
//
//    // MARK: - Table view data source
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return reminders.count
//    }
//
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "reminderCell", for: indexPath) as! ReminderTableViewCell
//        let reminder = reminders[indexPath.row]
//        cell.dateLabel.text = reminder.fireDate.dateString + " at " + reminder.fireDate.timeString
//        print("Fires: \(reminder.fireDate.localeDescription), counter date: \(reminder.interval!.date.localeDescription)")
//        cell.intervalLabel.text = "Fires " + reminder.interval!.smartIntervalString(forDate: reminder.fireDate)
//
//        return cell
//    }
// 
//
//    
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
// 
//
//    
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let reminder = reminders[indexPath.row]
//            RemindersDataManager.main.remove(reminder: reminder)
//            refreshData()
//        }
//    }
//    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        selectedReminder = reminders[indexPath.row]
//        performSegue(withIdentifier: SegueID.editReminder, sender: nil)
//    }
//
//    
//    // MARK: - Navigation
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let reminder = selectedReminder,
//            let vc = segue.destination as? RemindersEditDateViewController {
//            vc.reminder = reminder
//            selectedReminder = nil
//            shouldSaveOnReturn = true
//        }
//        if let id = segue.identifier,
//            id == SegueID.newReminder,
//            let vc = segue.destination as? RemindersEditDateViewController {
//            vc.reminder = RemindersDataManager.main.newReminder(for: interval)
//            shouldSaveOnReturn = true
//        }
//    }
// 
//    // MARK: - Convenience
//    
//    func refreshData() {
//        reminders = RemindersDataManager.main.reminders(forIntervalCreationDate: interval.creationDate)
//        tableView.reloadData()
//    }
//
//}
//
//// Helper function inserted by Swift 4.2 migrator.
//fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
//	guard let input = input else { return nil }
//	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
//}
//
//// Helper function inserted by Swift 4.2 migrator.
//fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
//	return input.rawValue
//}
