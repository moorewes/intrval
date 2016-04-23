//
//  NotificationHelper.swift
//  Interval
//
//  Created by Wesley Moore on 4/19/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import UIKit
import NotificationCenter

class NotificationHelper {
    class func askPermission() {
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    class func changeBadge(number: Int) {
        UIApplication.sharedApplication().applicationIconBadgeNumber = number
    }
    class func scheduleNotification(date: NSDate, message: String) {
        let notification = UILocalNotification()
        notification.fireDate = date
        notification.alertBody = message
        notification.timeZone = NSTimeZone.localTimeZone()
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
}

