//
//  Extensions.swift
//  Interval
//
//  Created by Wesley Moore on 4/19/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import UIKit

extension UILabel {
    func requiredHeight() -> CGFloat {
        let label = UILabel(frame: CGRectMake(0, 0, self.frame.width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = self.font
        label.text = self.text
        label.sizeToFit()
        return label.frame.height
    }
}
extension NSDate {
    var localeDescription: String { return self.descriptionWithLocale(NSCalendar.currentCalendar().locale) }
    var year: Int {
        let result = NSCalendar.currentCalendar().component(.Year, fromDate: self)
        return result
    }
    var month: Int {
        let result = NSCalendar.currentCalendar().component(.Month, fromDate: self)
        return result
    }
    var dayOfMonth: Int {
        let result = NSCalendar.currentCalendar().component(.Day, fromDate: self)
        return result
    }
    var daysFromNow: Int {
        let interval = NSCalendar.currentCalendar().components(.Day, fromDate: NSDate(), toDate: self, options: NSCalendarOptions()).day
        return interval
    }
}