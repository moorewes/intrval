//
//  ComplicationData.swift
//  Interval
//
//  Created by Wesley Moore on 4/2/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import Foundation

class ComplicationDataHelper {
    
    // MARK: - Types

    private enum UDKey {
        
        static let currentInterval = "currentIntervalData"
        static let allIntervals = "watchIntervalData"
        static let defaultUnit = "defaultUnit"
        static let userPrefersDefaultUnit = "userPrefersDefaultUnit"
        static let showSecondUnit = "shouldShowSecondUnit"
        static let useTopRowForTitle = "useTopRowForTitle"
        
    }
    
    private enum Legacy {
        
        static let referenceDate = "referenceDate"
        static let intervalUnit = "intervalUnit"
        static let title = "title"
        static let showSecondUnit = "showSecondUnit"
        
    }
    
    // MARK: - Properties
    
    private static let defaults = UserDefaults.standard
    
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
    
    internal class func allIntervals() -> [WatchCounter] {
        guard let data = UserDefaults.standard.object(forKey: UDKey.allIntervals) as? [String: Any],
        let array = data[UDKey.allIntervals] as? [[String: Any]] else {
                print("Couldn't fetch data for watch interface")
                return []
        }
        var result = [WatchCounter]()
        for info in array {
            let interval = WatchCounter(storageInfo: info)
            result.append(interval)
        }
        return result
    }
    
    internal class func currentInterval() -> WatchCounter? {
        guard let info = defaults.object(forKey: UDKey.currentInterval) as? [String:Any] else {
            return nil
        }
        let interval = WatchCounter(storageInfo: info)
        if userPrefersDefaultUnit {
            interval.unit = defaultUnit
        }
        return interval
    }

    // MARK: Convenience
    
    internal class func setCurrent(interval: WatchCounter?) {
        guard let int = interval else {
            defaults.set(nil, forKey: UDKey.currentInterval)
            return
        }
        let object = int.asStorageDict()
        defaults.set(object, forKey: UDKey.currentInterval)
    }
    
    internal class func importTransferData(_ data: [[String: Any]]) {
        var intervals = [WatchCounter]()
        for dict in data {
            if let interval = WatchCounter(transferDict: dict) {
                intervals.append(interval)
                print("success in processing transfer interval")
            } else {
                print("failed to process transfer interval: \(dict.debugDescription)")
            }
        }
        
        save(intervals)
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
    
    private class func save(_ intervals: [WatchCounter]) {
        let objectToSave = userDefaultsObject(forAll: intervals)
        defaults.set(objectToSave, forKey: UDKey.allIntervals)
        
        updateCurrentInterval()
        NotificationCenter.default.post(name: .watchIntervalDataUpdated, object: nil)
    }
    
    private class func userDefaultsObject(forAll intervals: [WatchCounter]) -> [String: Any] {
        var dictArray = [[String: Any]]()
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
                return
            }
        }
        
        // Will only get here if current interval was deleted on this update
        setCurrent(interval: intervals.first)
    }
    
    
}
