//
//  UIViewExtensions.swift
//  Interval
//
//  Created by Wesley Moore on 9/9/20.
//  Copyright © 2020 Wes Moore. All rights reserved.
//

import UIKit

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
}
