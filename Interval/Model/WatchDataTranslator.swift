//
//  WatchDataTranslator.swift
//  Interval
//
//  Created by Wesley Moore on 4/2/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import Foundation

open class WatchDataTranslator {
    
    private static let dataKey = "allIntervalData"
    private static let dateKey = "date"
    private static let titleKey = "title"
    
    class func data(for counters: [Counter]) -> [String: Any] {
        var dictArray = [[String: Any]]()
        for counter in counters {
            var dict = [String: Any]()
            dict[dateKey] = counter.date
            dict[titleKey] = counter.description
            dictArray.append(dict)
        }
        
        let result: [String: Any] = [dataKey:dictArray]
        
        return result
    }
    
}
