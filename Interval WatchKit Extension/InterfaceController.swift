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

    // MARK: - Properties
    
    private var dataController = DataController.main
    
    var timer: Timer?
    var intervals: [WatchCounter] = []
    var currentInterval: WatchCounter? {
        didSet {
            if let interval = currentInterval {
                timerLabel.setDate(interval.date)
                timerLabel.setHidden(false)
                dateLabel.setText(dateString(for: interval))
                dateLabel.setHidden(false)
                let text = interval.inPast ? "Since" : "Until"
                dateDescriptorLabel.setText(text)
                dateDescriptorLabel.setHidden(false)
            } else {
                timerLabel.setHidden(true)
                dateLabel.setHidden(true)
                dateDescriptorLabel.setText("")
                dateDescriptorLabel.setHidden(true)
            }
        }
    }
    @IBOutlet var timerLabel: WKInterfaceTimer!
    @IBOutlet var dateLabel: WKInterfaceLabel!
    @IBOutlet var dateDescriptorLabel: WKInterfaceLabel!
    
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
    
    var counterSelectItems: [WKPickerItem] {
        var result = [WKPickerItem]()
        intervals = dataController.counters
        for interval in intervals {
            let item = WKPickerItem()
            item.title = interval.title
            result.append(item)
        }
        if result.isEmpty {
            let noneSelectedItem = WKPickerItem()
            noneSelectedItem.title = "None, open app"
            result.append(noneSelectedItem)
            currentInterval = nil
        }
        return result
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet var counterSelectPicker: WKInterfacePicker!
    @IBOutlet var firstUnitPicker: WKInterfacePicker!
    @IBOutlet var secondUnitToggle: WKInterfaceSwitch!
    @IBOutlet var topRowTitleToggle: WKInterfaceSwitch!
    
    // MARK: - IBActions
    
    @IBAction func didSelectCounterItem(_ value: Int) {
        let interval = intervals[value]
        currentInterval = interval
        dataController.complicationCounter = interval
        setTimerToUpdateComplication()
        print("updated current")
        
    }
    
    @IBAction func didSelectFirstUnit(_ value: Int) {
        // print("selected first: ", value)
        saveFirstUnitData(value)
        // Auto enable 2 units for smart auto
        if value == 0 {
            secondUnitToggle.setOn(true)
            didToggleSecondUnit(true)
        }
    }
    @IBAction func didToggleSecondUnit(_ value: Bool) {
        UserSettings.showOnlyOneUnit = !value
        setTimerToUpdateComplication()
    }
    @IBAction func didToggleTopRowTitle(_ value: Bool) {
        UserSettings.useTopRowForTitle = value
        setTimerToUpdateComplication()
    }
    
    // MARK: - Life Cycle
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        print("awake")
            // NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .watchIntervalDataUpdated, object: nil)
        NotificationCenter.default.addObserver(forName: .watchIntervalDataUpdated, object: nil, queue: nil) { [unowned self] (notification) in
            self.updateUI()
        }
        firstUnitPicker.setItems(firstUnitItems)
        updateUI()
        print("done awakening")
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        updateUI()
        print("willActivate")
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        timer?.fire()
    }
    
    // MARK: - Convenience
    

    func updateUI() {
        // Set First Unit
        // Note: .Era is used for Smart Auto
        let firstUnitRaw = UserSettings.defaultUnit
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
        let showSecondUnit = !UserSettings.showOnlyOneUnit
        secondUnitToggle.setOn(showSecondUnit)
        
        // Set top row title preference
        let useTopRowForTitle = UserSettings.useTopRowForTitle
        topRowTitleToggle.setOn(useTopRowForTitle)
        
        // Setup counter select picker
        counterSelectPicker.setItems(counterSelectItems)
        // Set currentSelected
        if let currentCounter = dataController.complicationCounter {
            for i in 0..<intervals.count {
                let interval = intervals[i]
                if interval.id == currentCounter.id {
                    currentInterval = interval
                    counterSelectPicker.setSelectedItemIndex(i)
                }
            }
        } else {
            counterSelectPicker.setSelectedItemIndex(0)
            currentInterval = nil
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
        UserSettings.defaultUnit = unitRaw
        setTimerToUpdateComplication()
    }
    
    func setTimerToUpdateComplication() {
        if let t = timer {
            // print("timer exists")
            t.fireDate = Date(timeIntervalSinceNow: 3)
        } else {
            // print("timer doesn't exist")
//            timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(updateComplication), userInfo: nil, repeats: false)
            timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { _ in
                self.updateComplication()
            })
        }
    }
    

    func updateComplication() {
        timer = nil
        print("updateComplication")
        if let delegate = WKExtension.shared().delegate as? ExtensionDelegate {
            delegate.updateComplication()
        }
        
    }
    
    func dateString(for counter: WatchCounter) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: counter.date)
    }
    
    

}

