//
//  CircleButton.swift
//  Happy
//
//  Created by Wesley Moore on 4/25/15.
//  Copyright (c) 2015 Wesley Moore. All rights reserved.
//

import UIKit

class CircleButton: UIButton {
    
    let filledColor = UIColor.lightGray
    
    var isFilled: Bool { return backgroundColor != UIColor.clear }
    
    func toggleFill() {
        if isFilled {
            backgroundColor = UIColor.clear
        } else {
            backgroundColor = filledColor
        }
    }
    
    func set(filled: Bool) {
        if filled {
            backgroundColor = filledColor
        } else {
            backgroundColor = UIColor.clear
        }
    }
    
    override func layoutSubviews() {
        layer.cornerRadius = bounds.height/2
        super.layoutSubviews()
        
    }
}

