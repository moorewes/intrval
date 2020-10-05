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
        self.container = NSPersistentContainer(name: Counter.modelName)
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
    }
    
    // MARK: - Methods
    
    func newCounter() -> Counter {
        let counter = Counter(context: container.viewContext)
        counter.title = ""
        counter.date = Date()
        counter.includeTime = false
        counter.id = UUID()
        
        return counter
    }
    
    func newCounter(title: String, date: Date, includeTime: Bool) -> Counter {
        let counter = Counter(context: container.viewContext)
        counter.title = title
        counter.date = date
        counter.includeTime = includeTime
        counter.id = UUID()
        
        return counter
    }
    
    func saveCounters() {
        guard viewContext.hasChanges else { return }
        
        do {
            try viewContext.save()
        } catch {
            fatalError("Failed to save changes made to counter. Error: \(error)")
        }
                
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
            let _ = newCounter(title: legacyCounter.title,
                                     date: legacyCounter.date,
                                     includeTime: legacyCounter.includeTime)
        }
        
        let moc = container.viewContext
        do {
            try moc.save()
        } catch {
            return
        }
        
        moc.reset()
        
        LegacyDataController.removeAllData()
    }
    
}
