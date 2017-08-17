//
//  ComplicationData.swift
//  Interval
//
//  Created by Wesley Moore on 4/2/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import Foundation

open class ComplicationDataHelper{
    
    fileprivate static let dataKey = "allIntervalData"
    fileprivate static let dateKey = "date"
    fileprivate static let titleKey = "title"
    fileprivate static let idKey = "id"
    
    open class func userInfo(for data: [Interval]) -> [String:Any] {
        var dictArray = [NSMutableDictionary]()
        for interval in data {
            let dict = NSMutableDictionary()
            dict[dateKey] = interval.date
            dict[titleKey] = interval.description
            dict[idKey] = interval.creationDate
            dictArray.append(dict)
        }
        let result: [String:Any] = [dataKey:dictArray]
        return result
    }
    
}
