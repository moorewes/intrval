//
//  ComplicationData.swift
//  Interval
//
//  Created by Wesley Moore on 4/2/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import Foundation

open class ComplicationDataHelper{
    
    fileprivate static let dateKey = "date"
    fileprivate static let titleKey = "title"
    
    open class func createUserInfo(_ date: Date, title: String) -> [String:AnyObject] {
        let dict: [String:AnyObject] = [dateKey:date as AnyObject, titleKey:title as AnyObject]
        return dict
    }
    open class func dataFromUserInfo(_ userInfo: [String:AnyObject]) -> (date: Date, title: String) {
        let date = userInfo[dateKey] as! Date
        let title = userInfo[titleKey] as! String
        return (date, title)
    }
    
}
