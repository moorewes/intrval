//
//  IntervalDetailTableViewController.swift
//  Interval
//
//  Created by Wesley Moore on 8/1/17.
//  Copyright © 2017 Wes Moore. All rights reserved.
//

import UIKit
import CoreData

protocol CounterDetailDelegate: class {
    func didFinish(viewController: CounterDetailTableViewController, didSave: Bool)
}

@IBDesignable
class CounterDetailTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var counter: Counter!
    weak var delegate: CounterDetailDelegate!
    var moc: NSManagedObjectContext?
        
    private var dateFormatter = DateFormatter()
    
    // MARK: - IBOutlets

    @IBOutlet weak private var titleTextField: UITextField!
    @IBOutlet weak private var datePicker: UIDatePicker!
    @IBOutlet weak private var includeTimeSwitch: UISwitch!
    
    // MARK: - IBActions
    
    @IBAction func dateWasChanged(_ sender: UIDatePicker) {
        let date = datePicker.date.withZeroSeconds
        counter.date = counter.includeTime ? date : date.withTime(hour: 0, minute: 0)
    }
    
    @IBAction func includeTimeWasChanged(_ sender: UISwitch) {
        counter.includeTime = sender.isOn
        refreshUI()
    }
    
    @IBAction func setDateToNow() {
        let now = Date().withZeroSeconds
        counter.date = counter.includeTime ? now : now.withTime(hour: 0, minute: 0)
        
        refreshDatePicker()
    }
    
    @IBAction func userSaved() {
        titleTextField.resignFirstResponder()
        
        delegate.didFinish(viewController: self, didSave: true)
    }
    
    @IBAction private func userCanceled() {
        delegate.didFinish(viewController: self, didSave: false)
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        setupView()
        
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
        datePicker.datePickerMode = counter.includeTime ? .dateAndTime : .date
        refreshDatePicker()
        includeTimeSwitch.isOn = counter.includeTime
    }
    
    private func setupView() {
        tableView.tableFooterView = UIView()
        
        setupDatePicker()
        
        refreshDatePicker()
        
        titleTextField.text = counter.title
        
        let tap = UITapGestureRecognizer(target: self.titleTextField,
                                         action: #selector(UITextField.resignFirstResponder))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func setupDatePicker() {
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .compact
        }
        
    }
    
    private func refreshDatePicker() {
        datePicker.date = counter.date
    }
        
}

extension CounterDetailTableViewController: UITextFieldDelegate {
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = titleTextField.text!
        counter.title = text.isEmpty ? "Unnamed Counter" : text
        counter.title = textField.text!
    }
    
}
