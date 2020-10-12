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
    
    // MARK: - Initializers
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        title = ""
        date = Date().withTime(hour: 0, minute: 0, second: 0)
        includeTime = false
        id = UUID()
    }
    
    // MARK: - Methods
    
    func asWatchCounter() -> WatchCounter {
        return WatchCounter(id: id, date: date, title: title, includeTime: includeTime)
    }
    
    /// Returns an Interval object by automatically picking a relevant unit,
    /// e.g. 2 minutes instead of 120 seconds
    func scaledTimeInterval() -> Interval {
        return Interval(date: date, includeTime: includeTime)
    }
    
}
