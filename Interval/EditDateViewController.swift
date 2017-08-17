//
//  EditDateViewController.swift
//  Interval
//
//  Created by Wesley Moore on 8/1/17.
//  Copyright © 2017 Wes Moore. All rights reserved.
//

import UIKit

class EditDateViewController: UIViewController {
    
    var interval: Interval!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBAction func saveEdit() {
        interval.date = datePicker.date.withZeroSeconds
        DataManager.main.update(interval: interval)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelEdit() {
        navigationController?.popViewController(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.date = interval.date
        // Do any additional setup after loading the view.
    }

}
