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
        
    var dateFormatter: DateFormatter!
    
    var datePicker: UIDatePicker!
    
    // MARK: - IBOutlets

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateCell: UITableViewCell!
    @IBOutlet weak var datePickerWheel: UIDatePicker!
    @IBOutlet weak var includeTimeSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var datePickerInline: UIDatePicker!
    
    // MARK: - IBActions
    
    @IBAction func dateWasChanged(_ sender: UIDatePicker) {
        
        counter.date = datePicker.date
                
    }
    
    @IBAction func includeTimeWasChanged(_ sender: UISwitch) {
        
        counter.includeTime = sender.isOn
        
        refreshUI()
        
    }
    
    @IBAction func setDateToNow() {
        
        let now = Date()
        counter.date = now
        datePicker.date = now
        
    }
    
    @IBAction func userSaved(_ sender: UIBarButtonItem) {
        
        counter.title = titleTextField.text!
        if counter.title.isEmpty {
            
            counter.title = "Unnamed Counter"
            
        }
        
        counter.date = datePicker.date
        
        do {
            try counter.managedObjectContext?.save()
            
            print("saved: \(counter.description)")
        } catch {
            fatalError("Failed to save changes made to counter. Error: \(error)")
        }
        
        navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func userCanceled(_ sender: Any) {
        
        if let context = counter.managedObjectContext {
            
            context.rollback()
            
        }
        
        navigationController?.popViewController(animated: true)
        
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
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self.titleTextField, action: #selector(UITextField.resignFirstResponder))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        refreshUI()
                
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        if counter.title == "" {
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

    @objc func dismissKeyboard() {
        
        counter.title = titleTextField.text!
        titleTextField.resignFirstResponder()
        
    }
    
}

extension CounterDetailTableViewController: UITextFieldDelegate {
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        dismissKeyboard()
        
        return true
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        counter.title = textField.text!
        
    }
    
}
