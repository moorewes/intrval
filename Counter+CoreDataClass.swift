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
    
    // MARK: - Methods
    
    func timeInterval(using unit: Calendar.Component? = nil) -> (value: Int, unit: Calendar.Component) {
        let component = unit ?? relativeTimeIntervalUnit()
        let components = Calendar.current.dateComponents([component], from: date, to: Date())
        guard let count = components.value(for: component) else {
            return (0, component)
        }
        
        return (count, component)
    }
    
    func relativeTimeIntervalUnit() -> Calendar.Component {
        
        let yearInterval = timeInterval(using: .year).value
        guard yearInterval < 1 else {
            return .year
        }
        
        let monthInterval = timeInterval(using: .month).value
        guard monthInterval < 1 else {
            return .month
        }
        
        let dayInterval = timeInterval(using: .day).value
        guard dayInterval < 1 && includeTime else {
            return .day
        }
        
        let hourInterval = timeInterval(using: .hour).value
        guard hourInterval < 1 else {
            return .hour
        }
        
        let secondInterval = timeInterval(using: .second).value
        guard secondInterval < 60 else {
            return .minute
        }
        
        return .second
    }

}
