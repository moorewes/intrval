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
    
    internal struct Entity {
        static let Counter = "Counter"
    }
    
    private struct DefaultsKeys {
        static let legacyCounterData = "intervalData"
    }
    
    // MARK: - Singleton Instance
    
    static let main = DataController()
    
    // MARK: - Properties
    
    lazy internal var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "CounterDataModel")
        
        container.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        
        return container
    }()
    
    lazy internal var defaultCounterFetchRequest: NSFetchRequest<Counter> = {
        
        let fetchRequest = NSFetchRequest<Counter>(entityName: Entity.Counter)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return fetchRequest
        
    }()
    
    // MARK: - Convenience
    
    internal func importLegacyUserDefaultCounters() {
        
        guard let legacyCounters = UserDefaults.standard.value(forKey: DefaultsKeys.legacyCounterData) as? [[String: AnyObject]] else {
            return
        }
        
    }
    
}
