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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([NSAttributedString.Key.font.rawValue: Theme.navigationBarFont, NSAttributedString.Key.foregroundColor.rawValue: UIColor.white])
        
        editButtonItem.setTitleTextAttributes(convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): Theme.navigationBarFont]), for: .normal)
        editButtonItem.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = editButtonItem
        
        helpBarButtonItem.setTitleTextAttributes(convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): Theme.navigationBarFont]), for: .normal)
        helpBarButtonItem.tintColor = UIColor.white
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.setTitleTextAttributes(convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): Theme.navigationBarFont]), for: .normal)
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.navigationBar.barTintColor = Theme.intrvalGreen
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshData()
        if !startupSyncComplete {
            DataManager.main.transferDataToWatch()
            showRateRequestIfNecessary()
            startupSyncComplete = true
        }
    }


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
 

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let cell = tableView.cellForRow(at: indexPath) as! IntervalTableViewCell
            let interval = cell.interval!
            DataManager.main.remove(interval: interval)
            refreshData()
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
    
    func showRateRequestIfNecessary() {
//        let count = DataManager.main.openCount()
//        if count > 5 {
//            let rateStatus = DataManager.main.rateStatus()
//
//            switch rateStatus {
//            case .unseen:
//                present(rateAlert1, animated: true, completion: nil)
//            case .deferredForNextTime:
//                DataManager.main.update(rateStatus: .deferredForNow)
//            case .deferredForNow:
//                present(rateAlert2, animated: true, completion: nil)
//            default:
//                break
//            }
//        }
    }
    
    func rateApp() {
        if let url = URL(string: "itms-apps://itunes.apple.com/us/app/app-name/id1111883763") {
            UIApplication.shared.open(url, options: [:]) { (fail) in
                return
            }
        }
    }
    
    var rateAlert1: UIAlertController {
        let title = "Be Heard"
        let message = "Please leave us a review on the App Store. You rock!"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionYes = UIAlertAction(title: "Yes, I do rock 🤘", style: UIAlertAction.Style.default) { _ in
            DataManager.main.update(rateStatus: .acceptedRequest)
            self.rateApp()
        }
        let actionLater = UIAlertAction(title: "Later", style: UIAlertAction.Style.default) { _ in
            DataManager.main.update(rateStatus: .deferredForNextTime)
        }
        let actionNo = UIAlertAction(title: "No", style: .default) { _ in
            DataManager.main.update(rateStatus: .rejectedRequest)
        }
        alert.addAction(actionYes)
        alert.addAction(actionLater)
        alert.addAction(actionNo)
        return alert
    }
    var rateAlert2: UIAlertController {
        let title = "Be Heard"
        let message = "Leave us a quick review on the App Store?"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionYes = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) { _ in
            DataManager.main.update(rateStatus: .acceptedRequest)
            self.rateApp()
        }
        let actionLater = UIAlertAction(title: "Later", style: UIAlertAction.Style.default) { _ in
            DataManager.main.update(rateStatus: .deferredForNextTime)
        }
        let actionNo = UIAlertAction(title: "No", style: .default) { _ in
            DataManager.main.update(rateStatus: .rejectedRequest)
        }
        alert.addAction(actionYes)
        alert.addAction(actionLater)
        alert.addAction(actionNo)
        return alert
    }
    
    

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}