//
//  DataStorageHelper.swift
//  Interval
//
//  Created by Wesley Moore on 4/1/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import Foundation


open class DataManager {
    fileprivate static let defaults = UserDefaults.standard
    open class func retrieveUserData() -> Interval? {
        guard let date = defaults.value(forKey: Keys.UD.referenceDate) as? Date,
            let unitRaw = defaults.value(forKey: Keys.UD.intervalUnit) as? UInt,
            let includeTime = defaults.value(forKey: Keys.UD.includeTime) as? Bool,
            let description = defaults.value(forKey: Keys.UD.title) as? String else {
                //assertionFailure("couldnt retrieve data")
                return nil
        }
        let unit = NSCalendar.Unit(rawValue: unitRaw)
        let interval = Interval(date: date, unit: unit, includeTime: includeTime, description: description)
        return interval
    }
    open class func saveUserData(_ interval: Interval) {
        defaults.setValue(interval.date, forKey: Keys.UD.referenceDate)
        defaults.setValue(interval.unit.rawValue, forKey: Keys.UD.intervalUnit)
        defaults.setValue(interval.includeTime, forKey: Keys.UD.includeTime)
        defaults.setValue(interval.description, forKey: Keys.UD.title)
        defaults.set(true, forKey: Keys.UD.hasSaved)
        //print("saved")
    }
}
