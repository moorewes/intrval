//
//  ComplicationData.swift
//  Interval
//
//  Created by Wesley Moore on 4/2/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import Foundation

public class ComplicationDataHelper{
    
    private static let dateKey = "date"
    private static let unitKey = "unit"
    
    public class func createUserInfo(date: NSDate, unit: NSCalendarUnit) -> [String:AnyObject] {
        let rawUnit: UInt = unit.rawValue
        let dict: [String:AnyObject] = [dateKey:date, unitKey:rawUnit]
        return dict
    }
    public class func dataFromUserInfo(userInfo: [String:AnyObject]) -> (NSDate, NSCalendarUnit) {
        let date = userInfo[dateKey] as! NSDate
        let unitRaw = userInfo[unitKey] as! UInt
        let unit = NSCalendarUnit(rawValue: unitRaw)
        return (date,unit)
    }
    
}