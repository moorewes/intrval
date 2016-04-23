//
//  CircleButton.swift
//  Interval
//
//  Created by Wesley Moore on 4/22/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import UIKit

class CircleButton: UIButton {

    var filled: Bool = false
    
    override func drawRect(rect: CGRect) {
        let circle = UIBezierPath(arcCenter: center, radius: bounds.height/3, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
        UIColor.greenColor().set()
        circle.stroke()
        if filled {
            circle.fill()
        }
    }
 

}
