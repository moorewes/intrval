//
//  ComplicationData.swift
//  Interval
//
//  Created by Wesley Moore on 4/2/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import Foundation

public class ComplicationDataHelper{
    
    private static let dateKey = "date"
    private static let titleKey = "title"
    
    public class func createUserInfo(date: NSDate, title: String) -> [String:AnyObject] {
        let dict: [String:AnyObject] = [dateKey:date, titleKey:title]
        return dict
    }
    public class func dataFromUserInfo(userInfo: [String:AnyObject]) -> (date: NSDate, title: String) {
        let date = userInfo[dateKey] as! NSDate
        let title = userInfo[titleKey] as! String
        return (date, title)
    }
    
}
