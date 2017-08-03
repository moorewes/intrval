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
    
    open class func createUserInfo(_ date: Date, title: String) -> [String:AnyObject] {
        let dict: [String:AnyObject] = [dateKey:date as AnyObject, titleKey:title as AnyObject]
        return dict
    }
//    open class func dataFromUserInfo(_ userInfo: [String:AnyObject]) -> (date: Date, title: String) {
//        let date = userInfo[dateKey] as! Date
//        let title = userInfo[titleKey] as! String
//        return (date, title)
//    }
    
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
    
//    open class func data(from info: [String:Any]) -> [(date: Date, title: String)]? {
//        guard let array = info[dataKey] as? [NSMutableDictionary] else {
//            print("couldn't get interval array from user info")
//            return nil
//        }
//        var result = [(date: Date, title: String)]()
//        for item in array {
//            let info = (date: item[dateKey] as! Date, title: item[titleKey] as! String)
//            result.append(info)
//        }
//        return result
//    }
    
}
