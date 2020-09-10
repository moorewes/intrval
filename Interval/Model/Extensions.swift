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
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = self.font
        label.text = self.text
        label.sizeToFit()
        return label.frame.height
    }
}
extension UITextField {
    func requiredHeight() -> CGFloat {
        let label = UITextField(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: CGFloat.greatestFiniteMagnitude))
        label.font = self.font
        label.text = self.text
        label.sizeToFit()
        return label.frame.height
    }
}
extension Date {
    var localeDescription: String { return self.description(with: Calendar.current.locale) }
    var year: Int {
        let result = (Calendar.current as NSCalendar).component(.year, from: self)
        return result
    }
    var month: Int {
        let result = (Calendar.current as NSCalendar).component(.month, from: self)
        return result
    }
    var dayOfMonth: Int {
        let result = (Calendar.current as NSCalendar).component(.day, from: self)
        return result
    }
    var daysFromNow: Int {
        let interval = (Calendar.current as NSCalendar).components(.day, from: Date(), to: self, options: NSCalendar.Options()).day
        return interval!
    }
    /// Returns an NSDate on the same calendar day as self, but with time components
    func withTime(hour: Int, minute: Int, second: Int = 0) -> Date {
        
        return Calendar.current.date(bySettingHour: hour, minute: minute, second: second, of: self)!
    }
    
    func withCurrentTime() -> Date {
        let now = Date()
        let hour = NSCalendar.current.component(.hour, from: now)
        let minute = NSCalendar.current.component(.minute, from: now)
        return self.withTime(hour: hour, minute: minute, second: 0)
    }
    
    /// String value of month/day/year of self formatted with no leading zeroes and two digit year, i.e. "8/9/10"
    var shortString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: self)
    }
    
    var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: self)
    }
    
    var timeString: String {
        let dF = DateFormatter()
        dF.timeStyle = .short
        return dF.string(from: self)
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

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
}
extension NSCalendar.Unit {
    func asString(plural: Bool = true) -> String {
        var answer: String
        switch self {
        case NSCalendar.Unit.day: answer = "Day"
        case NSCalendar.Unit.weekOfYear: answer = "Week"
        case NSCalendar.Unit.month: answer = "Month"
        case NSCalendar.Unit.year: answer = "Year"
        case NSCalendar.Unit.minute: answer = "Minute"
        case NSCalendar.Unit.hour: answer = "Hour"
        case NSCalendar.Unit.second: answer = "Second"
        default: answer = "Day"
        }
        if plural {
            answer += "s"
        }
        return answer
    }
}
extension Calendar.Component {
    init(unit: NSCalendar.Unit) {
        switch unit {
        case NSCalendar.Unit.day: self = .day
        case NSCalendar.Unit.month: self = .month
        case NSCalendar.Unit.year: self = .year
        case NSCalendar.Unit.hour: self = .hour
        case NSCalendar.Unit.minute: self = .minute
        case NSCalendar.Unit.second: self = .second
        case NSCalendar.Unit.weekOfYear: self = .weekOfYear
        default:
            assertionFailure("inappropriate unit")
            self = .day
        }
    }
}

