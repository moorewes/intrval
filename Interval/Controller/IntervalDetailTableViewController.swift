//
//  IntervalDetailTableViewController.swift
//  Interval
//
//  Created by Wesley Moore on 8/1/17.
//  Copyright © 2017 Wes Moore. All rights reserved.
//

import UIKit

class IntervalDetailTableViewController: UITableViewController {
    
    // MARK: - Types
    
    struct SegueID {
        private init() {}
        static let editDate = "editDate"
        static let editTime = "editTime"
        static let showAllReminders = "showAllReminders"
        static let chooseReminderType = "chooseReminderType"
        static let showReminderDetail = "showReminderDetail"
    }
    
    // MARK: - Properties
    
    var interval: Interval!
    var isNewInterval = false
    var isEditingDate = false
    var index: Int!
    var isFullyLoaded = false
    
    // MARK: - IBOutlets

    @IBOutlet weak var intervalLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var includeTimeSwitch: UISwitch!
    
    // MARK: - IBActions
    
    @IBAction func dateWasChanged(_ sender: UIDatePicker) {
        interval.date = interval.includeTime ? sender.date : sender.date.withZeroSeconds
        if isNewInterval {
            setIntervalLabel(hidden: false)
            isNewInterval = !isNewInterval
        }
        refreshUI()
    }
    
    @IBAction func includeTimeWasChanged(_ sender: UISwitch) {
        interval.includeTime = sender.isOn
        refreshUI()
    }
    @IBAction func setDateToNow() {
        interval.setDateToNow()
        refreshUI()
    }
    
    @IBAction func userSaved(_ sender: UIBarButtonItem) {
        DataManager.main.update(interval: interval)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func userCanceled(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshUI()
        title = ""
        tableView.tableFooterView = UIView()
        
        setIntervalLabel(hidden: isNewInterval)
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self.titleTextField, action: #selector(UITextField.resignFirstResponder))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
                
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFullyLoaded {
            refreshUI()
        }
        if interval.description.isEmpty {
            titleTextField.becomeFirstResponder()
        }

        let _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.updateInterval()
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

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dateVC = segue.destination as? EditDateViewController {
            dateVC.interval = interval
        } else if let timeVC = segue.destination as? EditTimeViewController {
            timeVC.interval = interval
        }
        if titleTextField.isFirstResponder {
            commitTitleEdits()
            titleTextField.resignFirstResponder()
        }
    }
    
    // MARK: - Convenience
    
    func refreshUI() {
        unitLabel.text = intervalUnitString()
        intervalLabel.text = "\(abs(interval.currentInterval(ofUnit: interval.smartAutoUnit())))"
        titleTextField.text = interval.description
        dateLabel.text = interval.dateString
        datePicker.datePickerMode = interval.includeTime ? .dateAndTime : .date
        datePicker.date = interval.date
        includeTimeSwitch.isOn = interval.includeTime
    }
    
    func commitTitleEdits() {
        interval.description = titleTextField.text!
    }
    
    @objc func dismissKeyboard() {
        titleTextField.resignFirstResponder()
    }
    
    private func toggleDateEditing() {
        
        // Date picker row is the bottom row
        let bottomRow = IndexPath(row: 4, section: 0)
        
        // Animate the date picker row insertion/removal
        if isEditingDate {
            tableView.insertRows(at: [bottomRow], with: .fade)
            tableView.scrollToRow(at: bottomRow, at: .none, animated: true)
        } else {
            tableView.deleteRows(at: [bottomRow], with: .fade)
        }
    }
    
    private func setIntervalLabel(hidden: Bool) {
        intervalLabel.isHidden = hidden
        unitLabel.isHidden = hidden
    }
        
    private func cellID(at indexPath: IndexPath) -> String {
        switch indexPath.row {
        case 0: return "intervalTimerCell"
        case 1: return "titleCell"
        case 2: return "includeTimeCell"
        case 3: return "dateCell"
        case 4: return isEditingDate ? "datePickerCell" : "setDateNowCell"
        default: return "setDateNowCell"
        }
    }
    
    func intervalUnitString() -> String {
        let intervalInt = interval.currentInterval()
        var result = unitString()
        result += intervalInt < 0 ? " until" : " since"
        return result
        
    }
    
    func unitString() -> String {
        var answer: String
        switch interval.smartAutoUnit() {
        case NSCalendar.Unit.day: answer = "Day"
        case NSCalendar.Unit.weekOfYear: answer = "Week"
        case NSCalendar.Unit.month: answer = "Month"
        case NSCalendar.Unit.year: answer = "Year"
        case NSCalendar.Unit.minute: answer = "Minute"
        case NSCalendar.Unit.hour: answer = "Hour"
        case NSCalendar.Unit.second: answer = "Second"
        default: answer = "Day"
        }
        let interval = abs(self.interval.currentInterval())
        if interval != 1 {
            answer += "s"
        }
        return answer
    }
    
    func updateInterval() {
        let number = abs(interval.currentInterval())
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        intervalLabel.text = formatter.string(from: NSNumber(value: number))
    }
}

extension IntervalDetailTableViewController {
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isEditingDate ? 5 : 4
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 3 {
            isEditingDate = !isEditingDate
            toggleDateEditing()
        }
    }
    
}

extension IntervalDetailTableViewController: UITextFieldDelegate {
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commitTitleEdits()
        textField.resignFirstResponder()
        if isNewInterval {
            isEditingDate = true
            toggleDateEditing()
        }
        return true
    }
    
}
