//
//  UserSettings.swift
//  Interval WatchKit Extension
//
//  Created by Wes Moore on 10/7/20.
//  Copyright © 2020 Wes Moore. All rights reserved.
//

import Foundation

class UserSettings {
    
    private enum Key {
        static let idForComplicationCounter = "idForComplicationCounter"
        static let currentInterval = "currentIntervalData"
        static let allIntervals = "watchIntervalData"
        static let defaultUnit = "defaultUnit"
        static let userPrefersSpecificUnit = "userPrefersDefaultUnit"
        static let showOnlyOneUnit = "shouldShowSecondUnit"
        static let useTopRowForTitle = "useTopRowForTitle"
    }
    
    private static let defaults = UserDefaults.standard
    
    class var idForComplicationCounter: UUID? {
        get {
            guard let string = defaults.string(forKey: Key.idForComplicationCounter) else {
                return nil
            }
            return UUID(uuidString: string)
        }
        set {
            let string = newValue?.uuidString
            defaults.setValue(string, forKey: Key.idForComplicationCounter)
        }
    }
    
    class var userPrefersSpecificUnit: Bool {
        get {
            return defaults.bool(forKey: Key.userPrefersSpecificUnit)
        }
        set {
            defaults.set(newValue, forKey: Key.userPrefersSpecificUnit)
        }
    }
    
    // Note: .era is used to represent smart auto unit
    class var defaultUnit: UInt {
        get {
            return defaults.value(forKey: Key.defaultUnit) as? UInt ?? NSCalendar.Unit.era.rawValue
        }
        set {
            defaults.set(newValue, forKey: Key.defaultUnit)
        }
    }
    
    class var showOnlyOneUnit: Bool {
        get {
            return defaults.bool(forKey: Key.showOnlyOneUnit)
        }
        set {
            defaults.set(newValue, forKey: Key.showOnlyOneUnit)
        }
    }
    
    class var useTopRowForTitle: Bool {
        get {
            return defaults.bool(forKey: Key.useTopRowForTitle)
        }
        set {
            defaults.set(newValue, forKey: Key.useTopRowForTitle)
        }
    }
    
}
