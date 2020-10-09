//
//  IntervalCalculator.swift
//  Interval
//
//  Created by Wes Moore on 10/8/20.
//  Copyright © 2020 Wes Moore. All rights reserved.
//

import Foundation

class IntervalCalculator {
    
    let date: Date
    let includeTime: Bool
    
    lazy var interval: Interval = {
        return Interval(date: date, unit: scaledDateUnit())
    }()
    
    init(date: Date, includeTime: Bool) {
        self.date = date
        self.includeTime = includeTime
    }
    
    private func scaledDateUnit() -> Calendar.Component {
        let yearInterval = Interval(date: date, unit: .year).absValue
        guard yearInterval < 1 else {
            return .year
        }
        
        let monthInterval = Interval(date: date, unit: .month).absValue
        guard monthInterval < 1 else {
            return .month
        }
        
        let dayInterval = Interval(date: date, unit: .day).absValue
        guard dayInterval < 1 && includeTime else {
            return .day
        }
        
        let hourInterval = Interval(date: date, unit: .hour).absValue
        guard hourInterval < 1 else {
            return .hour
        }
        
        let secondInterval = Interval(date: date, unit: .second).absValue
        guard secondInterval < 60 else {
            return .minute
        }
        
        return .second
    }
    
}
