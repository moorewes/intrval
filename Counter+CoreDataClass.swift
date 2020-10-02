//
//  Counter+CoreDataClass.swift
//  Interval
//
//  Created by Wes Moore on 9/28/20.
//  Copyright © 2020 Wes Moore. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Counter)
public class Counter: NSManagedObject {
    
    static let modelName = "CounterDataModel"
    
    // MARK: - Methods
    
    /// Returns an Interval object by automatically picking a relevant unit,
    /// e.g. 2 minutes instead of 120 seconds
    func scaledTimeInterval() -> Interval {
        let unit = scaledTimeIntervalUnit()
        return timeInterval(using: unit)
    }
    
    private func timeInterval(using unit: Calendar.Component) -> Interval {
        let component = unit
        return Interval(date: date, unit: component)
    }
    
    private func scaledTimeIntervalUnit() -> Calendar.Component {
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
