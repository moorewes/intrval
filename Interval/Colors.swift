//
//  TimeOfDay.swift
//  Interval
//
//  Created by Wesley Moore on 6/23/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import UIKit

class Colors {
    static let sharedInstance = Colors()
    
    // MARK: Color Definitions
    internal let intrvalBlack = UIColor(white: 0.1, alpha: 1)
    internal let intrvalWhite = UIColor(white: 0.9, alpha: 1)
    
    // MARK: Variables
    internal var nightMode: Bool!
        internal var bColor: UIColor!
    internal var tColor: UIColor!
    internal var selectedBColor: UIColor!
    internal var selectedTColor: UIColor!
    
    // MARK: Functions
    internal func refreshColors() {
        let hour = NSCalendar.currentCalendar().component(.Hour, fromDate: NSDate())
        if hour > 6 && hour < 20 {
            nightMode = false
        } else {
            nightMode = true
        }
        if nightMode == true {
            bColor = intrvalBlack
            tColor = intrvalWhite
            selectedBColor = UIColor.darkGrayColor()
            selectedTColor = UIColor.lightGrayColor()
        } else {
            bColor = intrvalWhite
            tColor = intrvalBlack
            selectedBColor = UIColor.lightGrayColor()
            selectedTColor = UIColor.darkGrayColor()
        }
    }
    
    // MARK: Lifecycle
    init() {
        refreshColors()
    }
}