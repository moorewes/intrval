//
//  Interval.swift
//  Interval
//
//  Created by Wesley Moore on 3/31/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import Foundation



open class Interval {
    open var date: Date
    open var unit: NSCalendar.Unit
    open var includeTime: Bool
    open var description: String
    open func measureIntervalToInt(_ toDate: Date? = nil) -> Int {
        var tDate = Date()
        if let tD = toDate {
            tDate = tD
        }
        let component = Calendar.Component.init(unit: unit)
        let interval = Calendar.current.dateComponents([component], from: date, to: tDate)
        let answer = interval.value(for: component)
        return answer!
    }
    open func cycleUnit() {
        switch unit {
        case NSCalendar.Unit.day: unit = .weekOfYear
        case NSCalendar.Unit.weekOfYear: unit = .month
        case NSCalendar.Unit.month: unit = .year
        case NSCalendar.Unit.year: unit = .minute
        case NSCalendar.Unit.minute: unit = .hour
        case NSCalendar.Unit.hour: unit = .day
        default: unit = .day
        }
    }
    open func measureIntervalToString() -> String {
        let interval = abs(measureIntervalToInt())
        let answer = "\(interval)"
        return answer
    }
    open var dateString: String {
        let dateFormatter = DateFormatter()
        if includeTime {
            dateFormatter.dateFormat = "M/dd/YYYY h:mm a"
        } else {
            dateFormatter.dateFormat = "M/dd/YYYY"
        }
        let result = dateFormatter.string(from: date)
        return result
    }
    open var unitString: String {
        var answer: String
        switch unit {
        case NSCalendar.Unit.day: answer = "DAY"
        case NSCalendar.Unit.weekOfYear: answer = "WEEK"
        case NSCalendar.Unit.month: answer = "MONTH"
        case NSCalendar.Unit.year: answer = "YEAR"
        case NSCalendar.Unit.minute: answer = "MINUTE"
        case NSCalendar.Unit.hour: answer = "HOUR"
        default: answer = "DAY"
        }
        let interval = abs(measureIntervalToInt())
        if interval != 1 {
            answer += "S"
        }
        return answer
    }
    public init(date: Date, unit: NSCalendar.Unit, includeTime: Bool, description: String){
        self.date = date
        self.unit = unit
        self.includeTime = includeTime
        self.description = description
    }
}
