//
//  EditTimeViewController.swift
//  Interval
//
//  Created by Wesley Moore on 8/1/17.
//  Copyright © 2017 Wes Moore. All rights reserved.
//

import UIKit

class EditTimeViewController: UIViewController {
    
    var interval: Interval!

    @IBOutlet weak var includeTimeSwitch: UISwitch!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var excludeTimeHelpLabel: UILabel!
    @IBOutlet weak var currentTimeButton: UIButton!
    
    @IBAction func toggleSwitch(_ sender: UISwitch) {
        timePicker.isHidden = !sender.isOn
        currentTimeButton.isHidden = !sender.isOn
        excludeTimeHelpLabel.isHidden = sender.isOn
    }
    @IBAction func setTimeToCurrent() {
        timePicker.date = timePicker.date.withCurrentTime()
    }
    
    @IBAction func cancelEdit() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveEdit() {
        interval.includeTime = includeTimeSwitch.isOn
        if interval.includeTime {
            interval.date = timePicker.date
        } else {
            interval.date = interval.date.withTime(hour: 0, minute: 0, second: 0)
        }
        DataManager.main.update(interval: interval)
        navigationController?.popViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshUI()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Convenience
    
    func refreshUI() {
        includeTimeSwitch.isOn = interval.includeTime
        timePicker.isHidden = !interval.includeTime
        currentTimeButton.isHidden = !interval.includeTime
        excludeTimeHelpLabel.isHidden = interval.includeTime
        timePicker.date = interval.date
    }
}
