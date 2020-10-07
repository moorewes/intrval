//
//  WatchInterval.swift
//  Interval
//
//  Created by Wesley Moore on 8/2/17.
//  Copyright © 2017 Wes Moore. All rights reserved.
//

import Foundation

class WatchCounter: Codable {
    
    var date: Date
    var title: String
    var id: UUID
    
    var inPast: Bool {
        return date < Date()
    }
    
    init(date: Date, title: String, id: UUID) {
        self.date = date
        self.title = title
        self.id = id
    }

}
