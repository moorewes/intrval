//
//  Interval.swift
//  Interval
//
//  Created by Wesley Moore on 3/31/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import Foundation

struct Interval {
    
    let value: Int
    let unit: Calendar.Component
    
    var absValue: Int { return abs(value) }
        
    init(date: Date, unit: Calendar.Component) {
        let components = Calendar.current.dateComponents([unit], from: Date(), to: date)

        // Documentation states this will only return nil if inputting .calendar or .timeZone
        self.value = components.value(for: unit)!

        self.unit = unit
    }
    
    init(date: Date, includeTime: Bool) {
        let calculator = IntervalCalculator(date: date, includeTime: includeTime)
        self = calculator.interval
    }
    
}

extension NSCalendar.Unit {
    
    init(component: Calendar.Component) {
        self.init()
        switch component {
        case .second: self = .second
        case .minute: self = .minute
        case .hour: self = .hour
        case .day: self = .day
        case .month: self = .month
        case .year: self = .year
        default: self = .day
        }
    }
    
    func nextSmallerUnit() -> NSCalendar.Unit? {
        switch self {
        case .year: return .month
        case .month: return .weekOfMonth
        case .day: return .hour
        case .hour: return .minute
        case .minute: return .second
        default: return nil
        }
    }
    
}
