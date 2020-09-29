//
//  RoundedCornerButton.swift
//  Interval
//
//  Created by Wes Moore on 9/28/20.
//  Copyright © 2020 Wes Moore. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedCornerButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 0 {
       didSet {
           layer.cornerRadius = cornerRadius
           layer.masksToBounds = cornerRadius > 0
       }
    }

}
