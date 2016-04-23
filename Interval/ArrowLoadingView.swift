//
//  ArrowLoadingView.swift
//  Interval
//
//  Created by Wesley Moore on 4/4/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import UIKit

class ArrowLoadingView: UIView {
    
    override func drawRect(rect: CGRect) {
        let rect = CGRect(x: bounds.midX-8, y: 0, width: 16, height: bounds.height)
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: .AllCorners, cornerRadii: CGSize(width: 10, height: 10))
        UIColor.whiteColor().setFill()
        path.fill()
    }
    

}
