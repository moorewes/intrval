//
//  InterfaceController.swift
//  Interval WatchKit Extension
//
//  Created by Wesley Moore on 3/31/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
    @IBOutlet var firstUnitPicker: WKInterfacePicker!
    @IBOutlet var secondUnitToggle: WKInterfaceSwitch!
    
    var timer: NSTimer?
    
    let kSmartAuto = "SMART AUTO"
    let kYear = "YEARS"
    let kMonth = "MONTHS"
    let kDay = "DAYS"
    let kHour = "HOURS"
    let kMinute = "MINUTES"
    
    var firstUnitItems: [WKPickerItem] {
        let autoItem = WKPickerItem()
        autoItem.title = kSmartAuto
        let yearItem = WKPickerItem()
        yearItem.title = kYear
        let monthItem = WKPickerItem()
        monthItem.title = kMonth
        let dayItem = WKPickerItem()
        dayItem.title = kDay
        let hourItem = WKPickerItem()
        hourItem.title = kHour
        let minuteItem = WKPickerItem()
        minuteItem.title = kMinute
        return [autoItem, yearItem, monthItem, dayItem, hourItem, minuteItem]
    }
    @IBAction func didSelectFirstUnit(value: Int) {
        // print("selected first: ", value)
        saveFirstUnitData(value)
        // Auto enable 2 units for smart auto
        if value == 0 {
            secondUnitToggle.setOn(true)
            saveSecondUnitData(true)
        }
    }
    @IBAction func didToggleSecondUnit(value: Bool) {
        saveSecondUnitData(value)
    }
    func updateUI() {
        // print("updateUI()")
        if let firstUnitRaw = NSUserDefaults.standardUserDefaults().valueForKey(Keys.UD.intervalUnit) as? UInt {
            // Set First Unit
            // Note: .Era is used for Smart Auto
            var item = 0
            let unit = NSCalendarUnit.init(rawValue: firstUnitRaw)
            switch unit {
            case NSCalendarUnit.Era: item = 0
            case NSCalendarUnit.Year: item = 1
            case NSCalendarUnit.Month: item = 2
            case NSCalendarUnit.Day: item = 3
            case NSCalendarUnit.Hour: item = 4
            case NSCalendarUnit.Minute: item = 5
            default: break
            }
            firstUnitPicker.setSelectedItemIndex(item)
            // Set Second Unit
            let showSecondUnit = NSUserDefaults.standardUserDefaults().boolForKey(Keys.UD.showSecondUnit)
            secondUnitToggle.setOn(showSecondUnit)
        } else {
            firstUnitPicker.setSelectedItemIndex(0)
        }
    }
    func saveFirstUnitData(unitValue: Int) {
        // Note: .Era is used for Smart Auto
        var unit: NSCalendarUnit!
        switch unitValue {
        case 0: unit = .Era
        case 1: unit = .Year
        case 2: unit = .Month
        case 3: unit = .Day
        case 4: unit = .Hour
        case 5: unit = .Minute
        default: unit = .Era
        }
        let unitRaw = unit.rawValue
        NSUserDefaults.standardUserDefaults().setValue(unitRaw, forKey: Keys.UD.intervalUnit)
        setTimerToUpdateComplication()
        // print("saved first unit: ", unit)
    }
    func saveSecondUnitData(include: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(include, forKey: Keys.UD.showSecondUnit)
        setTimerToUpdateComplication()
        // print("saved second unit: ", include)
    }
    func setTimerToUpdateComplication() {
        if let t = timer {
            // print("timer exists")
            t.fireDate = NSDate(timeIntervalSinceNow: 5)
        } else {
            // print("timer doesn't exist")
            timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(updateComplication), userInfo: nil, repeats: false)
        }
    }
    func updateComplication() {
        timer = nil
        // print("updateComplication")
        if let delegate = WKExtension.sharedExtension().delegate as? ExtensionDelegate {
            delegate.updateComplication()
        }
        
    }
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        firstUnitPicker.setItems(firstUnitItems)
        updateUI()
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        timer?.fire()
    }

}

