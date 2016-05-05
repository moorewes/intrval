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
    private static let titleKey = "title"
    
    public class func createUserInfo(date: NSDate, unit: NSCalendarUnit, title: String) -> [String:AnyObject] {
        let rawUnit: UInt = unit.rawValue
        let dict: [String:AnyObject] = [dateKey:date, unitKey:rawUnit, titleKey:title]
        return dict
    }
    public class func dataFromUserInfo(userInfo: [String:AnyObject]) -> (NSDate, NSCalendarUnit, String) {
        let date = userInfo[dateKey] as! NSDate
        let unitRaw = userInfo[unitKey] as! UInt
        let title = userInfo[titleKey] as! String
        let unit = NSCalendarUnit(rawValue: unitRaw)
        return (date,unit,title)
    }
    
}