//
//  RoundedCornerView.swift
//  Interval
//
//  Created by Wesley Moore on 9/9/20.
//  Copyright © 2020 Wes Moore. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedCornerView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
       didSet {
           layer.cornerRadius = cornerRadius
           layer.masksToBounds = cornerRadius > 0
       }
    }
    
}
