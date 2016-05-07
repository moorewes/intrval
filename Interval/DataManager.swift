//
//  DataStorageHelper.swift
//  Interval
//
//  Created by Wesley Moore on 4/1/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import Foundation


public class DataManager {
    private static let defaults = NSUserDefaults.standardUserDefaults()
    public class func retrieveUserData() -> Interval? {
        guard let date = defaults.valueForKey(Keys.UD.referenceDate) as? NSDate,
            let unitRaw = defaults.valueForKey(Keys.UD.intervalUnit) as? UInt,
            let includeTime = defaults.valueForKey(Keys.UD.includeTime) as? Bool,
            let description = defaults.valueForKey(Keys.UD.title) as? String else {
            return nil
        }
        let unit = NSCalendarUnit(rawValue: unitRaw)
        let interval = Interval(date: date, unit: unit, includeTime: includeTime, description: description)
        return interval
    }
    public class func saveUserData(interval: Interval) {
        defaults.setValue(interval.date, forKey: Keys.UD.referenceDate)
        defaults.setValue(interval.unit.rawValue, forKey: Keys.UD.intervalUnit)
        defaults.setValue(interval.includeTime, forKey: Keys.UD.includeTime)
        defaults.setValue(interval.description, forKey: Keys.UD.title)
        defaults.setBool(true, forKey: Keys.UD.hasSaved)
    }
}