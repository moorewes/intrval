//
//  Interval.swift
//  Interval
//
//  Created by Wesley Moore on 3/31/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import Foundation



public class Interval {
    public var date: NSDate
    public var unit: NSCalendarUnit
    public var includeTime: Bool
    public var description: String
    public func measureIntervalToInt(toDate: NSDate? = nil) -> Int {
        var tDate = NSDate()
        if let tD = toDate {
            tDate = tD
        }
        let interval = NSCalendar.currentCalendar().components(unit, fromDate: date, toDate: tDate, options: NSCalendarOptions())
        let answer = interval.valueForComponent(unit)
        return answer
    }
    public func cycleUnit() {
        switch unit {
        case NSCalendarUnit.Day: unit = .WeekOfYear
        case NSCalendarUnit.WeekOfYear: unit = .Month
        case NSCalendarUnit.Month: unit = .Year
        case NSCalendarUnit.Year: unit = .Minute
        case NSCalendarUnit.Minute: unit = .Hour
        case NSCalendarUnit.Hour: unit = .Day
        default: unit = .Day
        }
    }
    public func measureIntervalToString() -> String {
        let interval = abs(measureIntervalToInt())
        let answer = "\(interval)"
        return answer
    }
    public var dateString: String {
        let dateFormatter = NSDateFormatter()
        if includeTime {
            dateFormatter.dateFormat = "M/dd/YYYY h:mm a"
        } else {
            dateFormatter.dateFormat = "M/dd/YYYY"
        }
        let result = dateFormatter.stringFromDate(date)
        return result
    }
    public var unitString: String {
        var answer: String
        switch unit {
        case NSCalendarUnit.Day: answer = "DAY"
        case NSCalendarUnit.WeekOfYear: answer = "WEEK"
        case NSCalendarUnit.Month: answer = "MONTH"
        case NSCalendarUnit.Year: answer = "YEAR"
        case NSCalendarUnit.Minute: answer = "MINUTE"
        case NSCalendarUnit.Hour: answer = "HOUR"
        default: answer = "DAY"
        }
        let interval = measureIntervalToInt()
        if interval != 1 {
            answer += "S"
        }
        return answer
    }
    public init(date: NSDate, unit: NSCalendarUnit, includeTime: Bool, description: String){
        self.date = date
        self.unit = unit
        self.includeTime = includeTime
        self.description = description
    }
}