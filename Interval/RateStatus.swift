//
//  RateStatus.swift
//  Interval
//
//  Created by Wesley Moore on 9/23/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import Foundation
public enum RateAlertStatus: Int {
    case unseen = 0
    case acceptedRequest = 1
    case deferredForNextTime = 2
    case rejectedRequest = 3
    case deferredForNow = 4
    
    public init(rawValue: Int) {
        switch rawValue {
        case 0: self = .unseen
        case 1: self = .acceptedRequest
        case 2: self = .deferredForNextTime
        case 3: self = .rejectedRequest
        case 4: self = .deferredForNow
        default:
            self = .unseen
        }
    }
}
