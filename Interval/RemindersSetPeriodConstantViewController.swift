//
//  RemindersSetPeriodConstantViewController.swift
//  Interval
//
//  Created by Wesley Moore on 8/3/17.
//  Copyright © 2017 Wes Moore. All rights reserved.
//

import UIKit

class RemindersSetPeriodConstantViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var constantTextField: UITextField!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var fireDateLabel: UILabel!
    
    var unit: Calendar.Component!
    var interval: Interval!

    @IBAction func editedConstant() {
        updateUI()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let unit = self.unit!
        let dateS = interval.dateString + " " + interval.timeString
        switch unit {
        case Calendar.Component.month: unitLabel.text = "Months from\n\(dateS)"
        case Calendar.Component.weekOfYear: unitLabel.text = "Weeks from\n\(dateS)"
        case Calendar.Component.day: unitLabel.text = "Days from\n\(dateS)"
        case Calendar.Component.hour: unitLabel.text = "Hours from\n\(dateS)"
        case Calendar.Component.minute: unitLabel.text = "Minutes from\n\(dateS)"
        default: break
        }
        constantTextField.text = ""
        fireDateLabel.text = ""
        constantTextField.becomeFirstResponder()
        updateUI()
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: - UITextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        updateUI()
        textField.resignFirstResponder()
        return false
    }
    
    // MARK: - Convenience
    
    func updateUI() {
        
        if let constant = Int(constantTextField.text!) {
            var newConstant = constant
            var newUnit = unit!
            if unit == .weekOfYear {
                newConstant = constant * 7
                newUnit = .day
            }
            if let fireDate = interval.dateForInterval(unit: newUnit, constant: newConstant) {
                let df = DateFormatter()
                df.dateStyle = .medium
                df.timeStyle = .none
                let tf = DateFormatter()
                tf.timeStyle = .short
                tf.dateStyle = .none
                let dateS = df.string(from: fireDate)
                let timeS = tf.string(from: fireDate)
                fireDateLabel.text = "Alert will fire on " + dateS + " at " + timeS
            } else {
                fireDateLabel.text = ""
            }
        } else {
            fireDateLabel.text = "Please enter a valid number"
        }
    }
    }
