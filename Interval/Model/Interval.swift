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
    
}
