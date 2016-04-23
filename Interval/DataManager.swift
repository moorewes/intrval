//
//  DataStorageHelper.swift
//  Interval
//
//  Created by Wesley Moore on 4/1/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import Foundation


public class DataManager {
    private static let defaults = NSUserDefaults(suiteName: Keys.UD.appGroup)!
    public class func retrieveUserData() -> Interval? {
        guard let date = defaults.valueForKey(Keys.UD.referenceDate) as? NSDate else {
            return nil
        }
        let unitRaw = defaults.valueForKey(Keys.UD.intervalUnit) as! UInt
        let formatRaw = defaults.valueForKey(Keys.UD.digitFormat) as! Int
        let includeTime = defaults.valueForKey(Keys.UD.includeTime) as! Bool
        let description = defaults.valueForKey(Keys.UD.description) as! String
        let unit = NSCalendarUnit(rawValue: unitRaw)
        let format = DigitFormat(rawValue: formatRaw)
        let interval = Interval(date: date, unit: unit, format: format, includeTime: includeTime, description: description)
        return interval
    }
    public class func saveUserData(interval: Interval) {
        //make in background
        defaults.setValue(interval.date, forKey: Keys.UD.referenceDate)
        defaults.setValue(interval.unit.rawValue, forKey: Keys.UD.intervalUnit)
        defaults.setValue(interval.digitFormat.rawValue, forKey: Keys.UD.digitFormat)
        defaults.setValue(interval.includeTime, forKey: Keys.UD.includeTime)
        defaults.setValue(interval.description, forKey: Keys.UD.description)
    }
}