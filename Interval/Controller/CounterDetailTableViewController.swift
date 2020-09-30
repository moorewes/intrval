//
//  IntervalDetailTableViewController.swift
//  Interval
//
//  Created by Wesley Moore on 8/1/17.
//  Copyright © 2017 Wes Moore. All rights reserved.
//

import UIKit

@IBDesignable
class CounterDetailTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var counter: Counter!
    
    var onDoneBlock: (() -> Void)?
    
    private var dateFormatter: DateFormatter!
    private var datePicker: UIDatePicker!
    
    // MARK: - IBOutlets

    @IBOutlet weak private var titleTextField: UITextField!
    @IBOutlet weak private var dateLabel: UILabel!
    @IBOutlet weak private var dateCell: UITableViewCell!
    @IBOutlet weak private var datePickerWheel: UIDatePicker!
    @IBOutlet weak private var includeTimeSwitch: UISwitch!
    @IBOutlet weak private var saveButton: UIBarButtonItem!
    @IBOutlet weak private var datePickerInline: UIDatePicker!
    
    // MARK: - IBActions
    
    @IBAction private func dateWasChanged(_ sender: UIDatePicker) {
        counter.date = datePicker.date
    }
    
    @IBAction private func includeTimeWasChanged(_ sender: UISwitch) {
        counter.includeTime = sender.isOn
        refreshUI()
    }
    
    @IBAction private func setDateToNow() {
        let now = Date()
        counter.date = now
        datePicker.date = now
    }
    
    @IBAction private func userSaved() {
        counter.title = titleTextField.text!
        if counter.title.isEmpty {
            counter.title = "Unnamed Counter"
        }
        
        counter.date = datePicker.date
        
        do {
            try counter.managedObjectContext?.save()
        } catch {
            fatalError("Failed to save changes made to counter. Error: \(error)")
        }
        
        dismiss(animated: true, completion: onDoneBlock)
    }
    
    @IBAction private func userCanceled() {
        if let moc = counter.managedObjectContext {
            moc.rollback()
        }
        
        dismiss(animated: true, completion: onDoneBlock)
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        setupDatePicker()
        
        datePicker.date = counter.date
        
        titleTextField.text = counter.title
        
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self.titleTextField,
                                                                  action: #selector(UITextField.resignFirstResponder))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        refreshUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        if counter.title.isEmpty {
            titleTextField.becomeFirstResponder()
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if titleTextField.isFirstResponder {
            titleTextField.resignFirstResponder()
        }
    }
    
    // MARK: - Convenience
    
    func refreshUI() {
        dateFormatter.timeStyle = counter.includeTime ? .short : .none
        dateLabel.text = dateFormatter.string(from: counter.date)
        
        datePicker.datePickerMode = counter.includeTime ? .dateAndTime : .date
        
        includeTimeSwitch.isOn = counter.includeTime
    }
    
    fileprivate func setupDatePicker() {
        // Enable pop-up date editing mode if possible as it's more user friendly
        if #available(iOS 14, *) {
            datePicker = datePickerInline
            datePicker.preferredDatePickerStyle = .compact
            datePickerWheel.isHidden = true
            dateLabel.isHidden = true
        } else {
            datePicker = datePickerWheel
            datePickerInline.isHidden = true
        }
        
        datePicker.isHidden = false
    }
}

extension CounterDetailTableViewController: UITextFieldDelegate {
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        counter.title = titleTextField.text!
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        counter.title = textField.text!
    }
}
