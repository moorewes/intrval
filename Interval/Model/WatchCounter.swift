//
//  WatchInterval.swift
//  Interval
//
//  Created by Wesley Moore on 8/2/17.
//  Copyright © 2017 Wes Moore. All rights reserved.
//

import Foundation

struct WatchCounter: Codable {
    
    private enum Key {
        static let date = "date"
        static let title = "title"
        static let id = "id"
        static let unit = "unit"
    }
    
    var date: Date
    var title: String
    var id: UUID
    var unit: UInt = NSCalendar.Unit.era.rawValue
    
    var dateString: String {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        return df.string(from: date)
    }
    
    var isBeforeNow: Bool {
        return date < Date()
    }
    
    init(date: Date, title: String, id: UUID) {
        self.date = date
        self.title = title
        self.id = id
    }

    
}
