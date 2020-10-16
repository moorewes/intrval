//
//  Extensions.swift
//  Interval
//
//  Created by Wesley Moore on 4/19/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import UIKit

extension Date {

    func withTime(hour: Int, minute: Int, second: Int = 0) -> Date {
        
        return Calendar.current.date(bySettingHour: hour, minute: minute, second: second, of: self)!
    }

    var withZeroSeconds: Date {
        let calender = Calendar.current
        let dateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        return calender.date(from: dateComponents)!
    }
    
}
extension Bundle {
    
    var releaseVersionNumber: String? {
        return self.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var buildVersionNumber: String? {
        return self.infoDictionary?["CFBundleVersion"] as? String
    }
    
}
