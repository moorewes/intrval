//
//  LegacyDataController.swift
//  Interval
//
//  Created by Wes Moore on 9/29/20.
//  Copyright © 2020 Wes Moore. All rights reserved.
//

import Foundation

class LegacyDataController {
    
    // MARK: - Types
    
    struct LegacyCounter {
        
        let date: Date
        let title: String
        let includeTime: Bool
        
        init?(dict: [String: AnyObject]) {
            guard let title = dict[Keys.title] as? String,
                  let date = dict[Keys.date] as? Date,
                  let includeTime = dict[Keys.includeTime] as? Bool else {
                return nil
            }
            self.title = title
            self.date = date
            self.includeTime = includeTime
        }
        
    }
    
    private enum Keys {
        
        static let intervalData = "intervalData"
        static let title = "title"
        static let date = "referenceDate"
        static let includeTime = "includeTime"
        
    }
    
    // MARK: - Methods
    
    class func counters() -> [LegacyCounter]? {
        guard let dict = UserDefaults.standard.object(forKey: Keys.intervalData)
                as? [[String: AnyObject]] else { return nil }
        
        var counters = [LegacyCounter]()
        for item in dict {
            if let counter = LegacyCounter(dict: item) { counters.append(counter) }
        }
        
        return counters
    }
    
    class func removeAllData() {
        UserDefaults.standard.removeObject(forKey: Keys.intervalData)
    }
    
}
