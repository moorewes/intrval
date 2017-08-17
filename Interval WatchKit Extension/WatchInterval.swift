//
//  WatchInterval.swift
//  Interval
//
//  Created by Wesley Moore on 8/2/17.
//  Copyright © 2017 Wes Moore. All rights reserved.
//

import Foundation

class WatchInterval {
    
    struct Key {
        fileprivate static let date = "date"
        fileprivate static let title = "title"
        fileprivate static let id = "id"
        fileprivate static let unit = "unit"
    }
    
    var date: Date
    var title: String
    var id: Date
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
    
    init(date: Date, title: String, id: Date) {
        self.date = date
        self.title = title
        self.id = id
    }
    
    convenience init(storageInfo info: [String:Any]) {
        let date = info[Key.date] as! Date
        let title = info[Key.title] as! String
        let id = info[Key.id] as! Date
        self.init(date: date, title: title, id: id)
        self.unit = info[Key.unit] as? UInt ?? self.unit
    }
    
    convenience init?(transferInfo info: [String:Any]) {
        if let date = info[Key.date] as? Date,
            let title = info[Key.title] as? String,
            let id = info[Key.id] as? Date {
            self.init(date: date, title: title, id: id)
        } else {
            return nil
        }
        
    }
    
    func asTransferDict() -> [String: Any] {
        let dict = NSMutableDictionary()
        dict[Key.date] = date
        dict[Key.title] = title
        dict[Key.id] = id
        return dict as! [String: Any]
    }
    
    func asStorageDict() -> [String: Any] {
        let dict = NSMutableDictionary()
        dict[Key.date] = date
        dict[Key.title] = title
        dict[Key.id] = id
        dict[Key.unit] = unit
        return dict as! [String:Any]
    }
    
}
