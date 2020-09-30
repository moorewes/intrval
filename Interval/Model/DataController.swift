/*
 
  DataController.swift
  Interval

  Created by Wes Moore on 9/28/20.
  Copyright © 2020 Wes Moore. All rights reserved.
 
*/

import Foundation
import CoreData

internal class DataController {
    
    // MARK: - Types
    
    enum Entity {
        static let Counter = "Counter"
    }
    
    private enum DefaultsKeys {
        static let legacyCounterData = "intervalData"
    }
    
    // MARK: - Properties
    
    // MARK: Singleton Instance
    
    static let main = DataController()
    
    // MARK: Internal Properties
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CounterDataModel")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        
        return container
    }()
    
    // MARK: - Init
    
    init() {
        importLegacyDataIfNeeded()
    }
    
    // MARK: - Methods
        
    private func importLegacyDataIfNeeded() {
        guard let legacyCounters = LegacyDataController.counters() else { return }
        
        let moc = persistentContainer.viewContext
        for legacyCounter in legacyCounters {
            let counter = Counter(context: moc)
            counter.title = legacyCounter.title
            counter.date = legacyCounter.date
            counter.includeTime = legacyCounter.includeTime
        }
        
        do {
            try moc.save()
        } catch {
            return
        }
        
        moc.reset()
        LegacyDataController.removeAllData()
    }
    
}
