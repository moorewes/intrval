//
//  WatchDataTranslator.swift
//  Interval
//
//  Created by Wesley Moore on 4/2/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import Foundation
import CoreData

open class WatchDataTranslator {
    
    private static let dataKey = "allIntervalData"
    private static let dateKey = "date"
    private static let titleKey = "title"
    
    class func data() -> [String: Any] {
        let context = DataController.main.container.newBackgroundContext()
        let fetchRequest: NSFetchRequest<Counter> = Counter.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        var counters = [Counter]()
        do {
            counters = try context.fetch(fetchRequest)
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
        
        var dictArray = [[String: Any]]()
        for counter in counters {
            var dict = [String: Any]()
            dict[dateKey] = counter.date
            dict[titleKey] = counter.title
            dictArray.append(dict)
        }
        
        let result: [String: Any] = [dataKey:dictArray]
        
        return result
    }
    
}
