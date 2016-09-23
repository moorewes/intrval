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
    internal let intrvalBlack = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)  // UIColor(white: 0.1, alpha: 1)
    internal let intrvalWhite = UIColor(red: 250/255, green: 255/255, blue: 250/255, alpha: 1)  // UIColor(white: 0.9, alpha: 1)
    
    // MARK: Variables
    internal var nightMode: Bool!
    internal var bColor: UIColor!
    internal var tColor: UIColor!
    internal var selectedBColor: UIColor!
    internal var selectedTColor: UIColor!
    
    // MARK: Functions
    internal func refreshColors() {
        let hour = (Calendar.current as NSCalendar).component(.hour, from: Date())
        if hour > 6 && hour < 20 {
            nightMode = false
        } else {
            nightMode = true
        }
        //nightMode = true
        if nightMode == true {
            bColor = intrvalBlack
            tColor = intrvalWhite
            selectedBColor = UIColor.darkGray
            selectedTColor = UIColor.lightGray
        } else {
            bColor = intrvalWhite
            tColor = intrvalBlack
            selectedBColor = UIColor.lightGray
            selectedTColor = UIColor.darkGray
        }
    }
    
    // MARK: Lifecycle
    init() {
        refreshColors()
    }
}
