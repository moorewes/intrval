//
//  WatchInterval.swift
//  Interval
//
//  Created by Wesley Moore on 8/2/17.
//  Copyright © 2017 Wes Moore. All rights reserved.
//

import Foundation

class WatchCounter: Codable, Identifiable {
    
    // MARK: - Properties
    
    var date: Date
    var title: String
    var includeTime: Bool
    var id: UUID
    
    var inPast: Bool {
        return date < Date()
    }
    
    // MARK: - Initializer
    
    init(id: UUID, date: Date, title: String, includeTime: Bool) {
        self.id = id
        self.date = date
        self.title = title
        self.includeTime = includeTime
    }

}

// MARK: - Equatable Conformance

extension WatchCounter: Equatable {
    
    static func == (lhs: WatchCounter, rhs: WatchCounter) -> Bool {
        return lhs.id == rhs.id
    }

}
