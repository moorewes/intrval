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
    
    open class func createUserInfo(_ date: Date, title: String) -> [String:Any] {
        let dict: [String:Any] = [dateKey:date as Any, titleKey:title as Any]
        return dict
    }
    open class func dataFromUserInfo(_ userInfo: [String:Any]) -> (date: Date, title: String) {
        let date = userInfo[dateKey] as! Date
        let title = userInfo[titleKey] as! String
        return (date, title)
    }
    
}
