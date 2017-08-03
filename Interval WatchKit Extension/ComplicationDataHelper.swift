//
//  ComplicationData.swift
//  Interval
//
//  Created by Wesley Moore on 4/2/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import Foundation

internal class ComplicationDataHelper {
    
//    struct UIKey {
//        fileprivate static let data = "data"
//        fileprivate static let date = "date"
//        fileprivate static let title = "title"
//        fileprivate static let id = "creationDate"
//    }
    
    struct UDKey {
        fileprivate static let currentInterval = "currentIntervalData"
        fileprivate static let allIntervals = "watchIntervalData"
        fileprivate static let defaultUnit = "defaultUnit"
        fileprivate static let userPrefersDefaultUnit = "userPrefersDefaultUnit"
        fileprivate static let showSecondUnit = "shouldShowSecondUnit"
        fileprivate static let useTopRowForTitle = "useTopRowForTitle"
        
        struct Legacy {
            fileprivate static let referenceDate = "referenceDate"
            fileprivate static let intervalUnit = "intervalUnit"
            fileprivate static let title = "title"
            fileprivate static let showSecondUnit = "showSecondUnit"
        }
        
    }
    
    // MARK: - Properties
    
    fileprivate static let defaults = UserDefaults.standard
    
    internal class var userPrefersDefaultUnit: Bool {
        get {
            return defaults.bool(forKey: UDKey.userPrefersDefaultUnit)
        }
        set {
            defaults.set(newValue, forKey: UDKey.userPrefersDefaultUnit)
        }
    }
    
    // Note: .era is used to represent smart auto unit
    internal class var defaultUnit: UInt {
        get {
            return defaults.value(forKey: UDKey.defaultUnit) as? UInt ?? NSCalendar.Unit.era.rawValue
        }
        set {
            defaults.set(newValue, forKey: UDKey.defaultUnit)
        }
    }
    
    internal class var showSecondUnit: Bool {
        get {
            return defaults.bool(forKey: UDKey.showSecondUnit)
        }
        set {
            defaults.set(newValue, forKey: UDKey.showSecondUnit)
        }
    }
    
    internal class var useTopRowForTitle: Bool {
        get {
            return defaults.bool(forKey: UDKey.useTopRowForTitle)
        }
        set {
            defaults.set(newValue, forKey: UDKey.useTopRowForTitle)
        }
    }
    
    
    // MARK: - Convenience (Retrieving)
    
    internal class func allIntervals() -> [WatchInterval] {
        guard let data = UserDefaults.standard.object(forKey: UDKey.allIntervals) as? [String:Any],
        let array = data[UDKey.allIntervals] as? [[String:Any]] else {
                print("Couldn't fetch data for watch interface")
                return []
        }
        var result = [WatchInterval]()
        for info in array {
            let interval = WatchInterval(storageInfo: info)
            result.append(interval)
        }
        return result
    }
    
    internal class func currentInterval() -> WatchInterval? {
        guard let info = defaults.object(forKey: UDKey.currentInterval) as? [String:Any] else {
            return nil
        }
        let interval = WatchInterval(storageInfo: info)
        if userPrefersDefaultUnit {
            interval.unit = defaultUnit
        }
        return interval
    }
    
    
    
    // MARK: - Helper (Retrieving)
    
    
    
    // MARK: - Convenience (Storing/Updating)
    
    internal class func setCurrent(interval: WatchInterval) {
        let object = interval.asStorageDict()
        defaults.set(object, forKey: UDKey.currentInterval)
    }
    
    internal class func saveAll(_ intervalTransferInfo: [[String:Any]]) {
        var intervals = [WatchInterval]()
        for item in intervalTransferInfo {
            if let interval = WatchInterval(transferInfo: item) {
                intervals.append(interval)
                print("success in processing transfer interval")
            } else {
                print("failed to process transfer interval: \(item.debugDescription)")
            }
        }
        saveAll(intervals)
    }
    
    internal class func initializeDefaultsIfNeeded() {
        if defaults.value(forKey: UDKey.userPrefersDefaultUnit) == nil {
            userPrefersDefaultUnit = true
        }
        if defaults.value(forKey: UDKey.showSecondUnit) == nil {
            showSecondUnit = true
        }
    }
    
    
    
    // MARK: - Helper (Storing/Updating)
    
    fileprivate class func saveAll(_ intervals: [WatchInterval]) {
        let objectToSave = userDefaultsObject(forAll: intervals)
        defaults.set(objectToSave, forKey: UDKey.allIntervals)
        
        // Update current interval in case changed with update
        updateCurrentInterval()
        NotificationCenter.default.post(name: .watchIntervalDataUpdated, object: nil)
    }
    
    fileprivate class func userDefaultsObject(forAll intervals: [WatchInterval]) -> [String:Any] {
        var dictArray = [[String:Any]]()
        for interval in intervals {
            let dict = interval.asStorageDict()
            dictArray.append(dict)
        }
        let result: [String:Any] = [UDKey.allIntervals:dictArray]
        return result
    }
    
    internal class func updateCurrentInterval() {
        let intervals = allIntervals()
        guard let current = currentInterval() else {
            // If no current set yet but some exist, pick the first and make it current
            if !intervals.isEmpty {
                setCurrent(interval: intervals.first!)
            }
            return
        }
        
        // Reload current in case changes occurred
        for interval in intervals {
            if interval.id == current.id {
                setCurrent(interval: interval)
            }
        }
    }
    
    
}
