//
//  Interval.swift
//  Interval
//
//  Created by Wesley Moore on 3/31/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import Foundation

public enum DigitFormat: Int {
    case Standard = 0, Roman
    public init(rawValue: Int){
        switch rawValue {
        case 0: self = .Standard
        case 1: self = .Roman
        default: self = .Standard
        }
    }
}

public class Interval {
    public var date: NSDate
    public var unit: NSCalendarUnit
    public var digitFormat: DigitFormat
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
    public func cycleDigitFormat() -> DigitFormat {
        switch digitFormat {
        case .Standard:
            digitFormat = .Roman
        case .Roman:
            digitFormat = .Standard
        }
        return digitFormat
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
        var answer: String!
        let interval = abs(measureIntervalToInt())
        switch digitFormat {
        case .Standard: answer = "\(interval)"
        case .Roman:
            guard interval != 0 else {
                return "0"
            }
            if let roman = String(roman: interval) {
                answer = roman
            }
        }
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
    public init(date: NSDate, unit: NSCalendarUnit, format: DigitFormat, includeTime: Bool, description: String){
        self.date = date
        self.unit = unit
        self.digitFormat = format
        self.includeTime = includeTime
        self.description = description
    }
}