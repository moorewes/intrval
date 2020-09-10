//
//  Reminder+CoreDataClass.swift
//  Interval
//
//  Created by Wesley Moore on 8/4/17.
//  Copyright © 2017 Wes Moore. All rights reserved.
//
//
//import Foundation
//import CoreData
//
//
//public class Reminder: NSManagedObject {
//    
//    var interval: Interval?
//    
//    var defaultMessage: String {
//        guard let interval = self.interval else {
//            return ""
//        }
//        let intervalString = interval.smartIntervalString(forDate: fireDate, pastPreposition: "Until", futurePreposition: "Since")
//        return intervalString
//        
//    }
//    
//    struct Key {
//        static let fireDate = "fireDate"
//        static let intervalCreationDate = "intervalCreationDate"
//    }
//    
//    public override func awakeFromFetch() {
//        super.awakeFromFetch()
//        print("reminder just awoke from fetch")
//        loadInterval()
//        
//    }
//    
//    public func loadInterval() {
//        if let interval = DataManager.main.interval(withCreationDate: intervalCreationDate) {
//            self.interval = interval
//        } else {
//            print("couldn't set interval")
//        }
//    }
//
//}
