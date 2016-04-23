//
//  UserSettings.swift
//  Interval
//
//  Created by Wesley Moore on 4/22/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import Foundation

class UserSettings {
    let defaults = NSUserDefaults.standardUserDefaults()
    var badgeIcon: Bool {
        get {
            return defaults.boolForKey(Keys.UD.badgeIcon)
        }
        set {
            defaults.setBool(newValue, forKey: Keys.UD.badgeIcon)
        }
    }
}