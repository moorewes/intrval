//
//  NotableIntervals.swift
//  Interval
//
//  Created by Wesley Moore on 4/20/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import Foundation


enum NotableUnit {
    case Year, Month, Week, Day, Hour, Minute, Second, JupiterYear, SaturnYear
}
enum NotificationFrequency: Int {
    case VeryLow = 1, Low, Medium, High, VeryHigh
    var description: String {
        var result = ""
        switch self {
        case .VeryLow: result = "Very Infrequent"
        case .Low: result = "Infrequent"
        case .Medium: result = "Occasional"
        case .High: result = "Often"
        case .VeryHigh: result = "Very Often"
        }
        return result
    }
}

class NotableNotification {
    var fireDate: NSDate
    var count: Int
    var unit: NotableUnit
    init(fireDate: NSDate, unit: NotableUnit, count: Int) {
        self.fireDate = fireDate
        self.unit = unit
        self.count = count
    }
}

class NotableNotificationsHelper {
    var maxDayInterval = 1120
    var interval: Interval
    var frequency: NotificationFrequency
    
    var countingUp: Bool {
        let now = NSDate()
        let result = interval.date.compare(now) == .OrderedAscending
        return result
    }
    
    
    func getNotableNotificationsForInterval(interval: Interval, frequency: NotificationFrequency) -> [NotableNotification] {
        var result = [NotableNotification]()
        result.append(oneYearNotification())
        
        return result
    }
    
    private func oneYearNotification() -> NotableNotification {
        // Definitions
        var result: NotableNotification!
        let baseDate = interval.date
        let components = NSDateComponents()
        var increment: Int { return countingUp ? 1 : -1 }
        var notableDate: NSDate!
        var isInPast: Bool { return NSDate().compare(notableDate) != .OrderedAscending }
        var incrementCount: Int { return components.year - baseDate.year }
        func incrementYear() {
            components.year += increment
            notableDate = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: baseDate, options: NSCalendarOptions())!
        }
        // Initialize
        components.year = 0
        incrementYear()
        // Execute loop until success
        while isInPast {
            incrementYear()
        }
        // Delivery
        var fireDate = notableDate
        if !interval.includeTime {
            let comps = NSDateComponents()
            comps.hour = 10
            comps.minute = 0
            fireDate = NSCalendar.currentCalendar().dateBySettingHour(10, minute: 0, second: 0, ofDate: fireDate, options: NSCalendarOptions())
        }
        let notification = NotableNotification(fireDate: fireDate, unit: .Year, count: incrementCount)
        return notification
    }
    
    init(interval: Interval, frequency: NotificationFrequency) {
        self.interval = interval
        self.frequency = frequency
    }
}

/* Types:
 
 1. Lowest
 -n years(Earth)
 -10^n >= 100 months
 -10^n >= 1000 days
 
 
 2. Lower
 -5 * 10^n >= 50 months
 -10^n >= 100 weeks
 -5 * 10^n >= 500 days
 -10^n >= 1000 hours (10k ~= 417 days, 100k ~= 11.4 years
 -10^n >= 100k minutes (100k ~= 69 days)
 
 -n * 4332 days Jupiter orbit
 -n * 10832 days Saturn orbit
 
 
 3. Medium
 -(2...4,6...9) * 10^n >= 200 months
 -5 * 10^n >= 500 weeks
 -(2...4,6...9) * 10^n >= 2000 days
 -5 * 10^n >= 5000 hours
 -5 * 10^n >= 50000 minutes
 
 
 
 
 4. High
 -(2...4,6...9) * 10^n >= 200 weeks
 -(1...10) * 10^n >= 2000 hours
 -(1...10) * 10^n >= 20000 minutes
 
 -n * 687 days Mars orbit
 -n * 224 days Venus orbit
 
 5. Highest
 
 -n * 88 days Mercury orbit
 
 */