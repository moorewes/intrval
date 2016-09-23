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
    
    var timer: Timer?
    
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
    @IBAction func didSelectFirstUnit(_ value: Int) {
        // print("selected first: ", value)
        saveFirstUnitData(value)
        // Auto enable 2 units for smart auto
        if value == 0 {
            secondUnitToggle.setOn(true)
            saveSecondUnitData(true)
        }
    }
    @IBAction func didToggleSecondUnit(_ value: Bool) {
        saveSecondUnitData(value)
    }
    func updateUI() {
        // print("updateUI()")
        if let firstUnitRaw = UserDefaults.standard.value(forKey: Keys.UD.intervalUnit) as? UInt {
            // Set First Unit
            // Note: .Era is used for Smart Auto
            var item = 0
            let unit = NSCalendar.Unit.init(rawValue: firstUnitRaw)
            switch unit {
            case NSCalendar.Unit.era: item = 0
            case NSCalendar.Unit.year: item = 1
            case NSCalendar.Unit.month: item = 2
            case NSCalendar.Unit.day: item = 3
            case NSCalendar.Unit.hour: item = 4
            case NSCalendar.Unit.minute: item = 5
            default: break
            }
            firstUnitPicker.setSelectedItemIndex(item)
            // Set Second Unit
            let showSecondUnit = UserDefaults.standard.bool(forKey: Keys.UD.showSecondUnit)
            secondUnitToggle.setOn(showSecondUnit)
        } else {
            firstUnitPicker.setSelectedItemIndex(0)
        }
    }
    func saveFirstUnitData(_ unitValue: Int) {
        // Note: .Era is used for Smart Auto
        var unit: NSCalendar.Unit!
        switch unitValue {
        case 0: unit = .era
        case 1: unit = .year
        case 2: unit = .month
        case 3: unit = .day
        case 4: unit = .hour
        case 5: unit = .minute
        default: unit = .era
        }
        let unitRaw = unit.rawValue
        UserDefaults.standard.setValue(unitRaw, forKey: Keys.UD.intervalUnit)
        setTimerToUpdateComplication()
        // print("saved first unit: ", unit)
    }
    func saveSecondUnitData(_ include: Bool) {
        UserDefaults.standard.set(include, forKey: Keys.UD.showSecondUnit)
        setTimerToUpdateComplication()
        // print("saved second unit: ", include)
    }
    func setTimerToUpdateComplication() {
        if let t = timer {
            // print("timer exists")
            t.fireDate = Date(timeIntervalSinceNow: 5)
        } else {
            // print("timer doesn't exist")
            timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateComplication), userInfo: nil, repeats: false)
        }
    }
    func updateComplication() {
        timer = nil
        // print("updateComplication")
        if let delegate = WKExtension.shared().delegate as? ExtensionDelegate {
            delegate.updateComplication()
        }
        
    }
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
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

