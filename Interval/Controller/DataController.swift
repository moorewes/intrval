/*
 
  DataController.swift
  Interval

  Created by Wes Moore on 9/28/20.
  Copyright © 2020 Wes Moore. All rights reserved.
 
*/

import Foundation
import CoreData

extension Notification.Name {
    static let counterDataDidUpdate = Notification.Name(rawValue: "counterDataDidUpdate")
}

internal class DataController {
    
    // MARK: - Types
    
    private enum DefaultsKeys {
        static let legacyCounterData = "intervalData"
    }
    
    // MARK: - Singleton Instance
    
    static let main = DataController()
    
    // MARK: - Properties
    
    // MARK: Internal
    
    var container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext { return container.viewContext }
            
    // MARK: - Init
    
    init() {
        WatchCommunicator.main.activateSession()
        
        self.container = NSPersistentContainer(name: Counter.modelName)
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        
        importLegacyDataIfNeeded()
    }
    
    // MARK: - Methods
    
    func newCounter(in providedMOC: NSManagedObjectContext? = nil) -> Counter {
        let moc: NSManagedObjectContext! = providedMOC == nil ?
                                           container.viewContext :
                                           providedMOC
        
        let counter = Counter(context: moc)
        
        return counter
    }
    
    func newCounter(title: String, date: Date, includeTime: Bool) -> Counter {
        let counter = Counter(context: container.viewContext)
        counter.title = title
        counter.date = date
        counter.includeTime = includeTime
        
        return counter
    }
    
    func saveCounters() {
        guard viewContext.hasChanges else { return }
        
        do {
            try viewContext.save()
        } catch {
            fatalError("Failed to save changes made to counter. Error: \(error)")
        }
        
        NotificationCenter.default.post(name: .counterDataDidUpdate, object: nil)
    }
    
    func discardChanges() {
        viewContext.rollback()
    }
        
    private func allCounters() -> [Counter] {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<Counter> = Counter.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        var objects = [Counter]()
        do {
            objects = try context.fetch(fetchRequest)
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
        return objects
    }
        
    private func importLegacyDataIfNeeded() {
        guard let legacyCounters = LegacyDataController.counters() else { return }
        
        for legacyCounter in legacyCounters {
            _ = newCounter(title: legacyCounter.title,
                                     date: legacyCounter.date,
                                     includeTime: legacyCounter.includeTime)
        }
        
        saveCounters()
        
        LegacyDataController.removeAllData()
    }
    
}
