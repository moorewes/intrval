//
//  Interval.swift
//  Interval
//
//  Created by Wesley Moore on 3/31/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import Foundation



open class Interval {
    
    struct Keys {
        public static let creationDate = "creationDate"
        public static let referenceDate = "referenceDate"
        public static let intervalUnit = "intervalUnit"
        public static let includeTime = "includeTime"
        public static let title = "title"
        private init() {}
    }
    open let creationDate: Date
    open var date: Date
    open var unit: NSCalendar.Unit
    open var includeTime: Bool
    open var description: String
    open func isCountingDown() -> Bool {
        return measureIntervalToInt() < 0
    }
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
        case NSCalendar.Unit.year: unit = .second
        case NSCalendar.Unit.second: unit = .minute
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
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        return df.string(from: date)
    }
    open var timeString: String {
        let df = DateFormatter()
        df.dateStyle = .none
        df.timeStyle = .short
        return df.string(from: date)
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
        case NSCalendar.Unit.second: answer = "SECOND"
        default: answer = "DAY"
        }
        let interval = abs(measureIntervalToInt())
        if interval != 1 {
            answer += "S"
        }
        return answer
    }
    open var unitStringLowercase: String {
        var answer: String
        switch unit {
        case NSCalendar.Unit.day: answer = "Day"
        case NSCalendar.Unit.weekOfYear: answer = "Week"
        case NSCalendar.Unit.month: answer = "Month"
        case NSCalendar.Unit.year: answer = "Year"
        case NSCalendar.Unit.minute: answer = "Minute"
        case NSCalendar.Unit.hour: answer = "Hour"
        case NSCalendar.Unit.second: answer = "Second"
        default: answer = "Day"
        }
        let interval = abs(measureIntervalToInt())
        if interval != 1 {
            answer += "s"
        }
        return answer
    }
    
    /// Returns user readable interval, for example "2 Years Remain" or "1 Month Has Passed"
    open func smartIntervalString() -> String {
        unit = smartAutoUnit()
        let int = measureIntervalToInt()
        var result = measureIntervalToString() + " " + unitStringLowercase
        if int < 0 {
            result += " Remain"
        } else if int == 1 {
            result += " Has Passed"
        } else {
            result += " Have Passed"
        }
        return result
    }
    
    func smartAutoUnit() -> NSCalendar.Unit {
        let yearInterval = intervalForUnit(.year, fromDate: date)
        guard yearInterval < 1 else {
            return .year
        }
        let monthInterval = intervalForUnit(.month, fromDate: date)
        guard monthInterval < 1 else {
            return .month
        }
        let dayInterval = intervalForUnit(.day, fromDate: date)
        guard dayInterval < 1 else {
            return .day
        }
        let hourInterval = intervalForUnit(.hour, fromDate: date)
        guard hourInterval < 1 else {
            return .hour
        }
        let secondInterval = intervalForUnit(.second, fromDate: date)
        guard secondInterval < 60 else {
            return .minute
        }
        return .second
    }
    
    func dateForInterval(unit: Calendar.Component, constant: Int) -> Date? {
        var newDate: Date?
        if isCountingDown() {
            newDate = NSCalendar.current.date(byAdding: unit, value: -constant, to: date)
        } else {
            newDate = NSCalendar.current.date(byAdding: unit, value: constant, to: date)
        }
        return newDate
    }
    
    func intervalForUnit(_ unit: NSCalendar.Unit, fromDate date: Date) -> Int {
        let component = Calendar.Component.init(unit: unit)
        let components = Calendar.current.dateComponents([component], from: date, to: Date())
        let count = components.value(for: component)!
        return abs(count)
    }
    
    public init(date: Date, unit: NSCalendar.Unit, includeTime: Bool, description: String, creationDate: Date){
        self.date = date
        self.unit = unit
        self.includeTime = includeTime
        self.description = description
        self.creationDate = creationDate
    }
    
    convenience init(dict: [String:AnyObject]) {
        let date = dict[Keys.referenceDate] as! Date
        let unitRaw = dict[Keys.intervalUnit] as! UInt
        let unit = NSCalendar.Unit(rawValue: unitRaw)
        let includeTime = dict[Keys.includeTime] as! Bool
        let description = dict[Keys.title] as! String
        let creationDate = dict[Keys.creationDate] as! Date
        self.init(date: date, unit: unit, includeTime: includeTime, description: description, creationDate: creationDate)
    }
    
    open func asDict() -> [String:AnyObject] {
        let dict: NSMutableDictionary = [:]
        dict[Keys.referenceDate] = date
        dict[Keys.intervalUnit] = unit.rawValue
        dict[Keys.includeTime] = includeTime
        dict[Keys.title] = description
        dict[Keys.creationDate] = creationDate
        return dict as! [String:AnyObject]
    }
    
}
