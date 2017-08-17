//
//  RemindersDataManager.swift
//  Interval
//
//  Created by Wesley Moore on 8/4/17.
//  Copyright © 2017 Wes Moore. All rights reserved.
//

import UIKit
import CoreData

class RemindersDataManager {
    
    static let main = RemindersDataManager()
    
    // MARK: - Properties
    
    let storeFileName = "Reminders.sqlite"
    let cache = "RemindersCache"

    
    private init() {
       clearOldReminders()
    }
    
    // MARK: - Convenience
    
    
    internal func reminders(forIntervalCreationDate date: Date) -> [Reminder] {
        var result = [Reminder]()
        guard let moc = moc else {
            return result
        }
        let request: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: Reminder.Key.fireDate, ascending: true)]
        request.predicate = NSPredicate(format: "%K == %@", argumentArray: [Reminder.Key.intervalCreationDate, date])
        do {
            result = try moc.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
        
//        for reminder in allReminders {
//            if reminder.intervalCreationDate == date {
//                result.append(reminder)
//            }
//            // Since sorting is by intervalCreationDate, can return after result has some and if test fails
//            if !result.isEmpty { return result }
//        }
        return result
    }
    
    internal func newReminder(for interval: Interval) -> Reminder {
        let reminder = Reminder(entity: NSEntityDescription.entity(forEntityName: "Reminder", in: moc!)!, insertInto: moc!)
        reminder.fireDate = interval.date
        reminder.intervalCreationDate = interval.creationDate
        reminder.message = interval.description
        reminder.loadInterval()
        return reminder
    }
    
    internal func remove(reminder: Reminder) {
        moc?.delete(reminder)
        save()
    }
    
    internal func requestPermission() {
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
    }
    
    internal func save() {
        do {
            try moc?.save()
            scheduleReminders()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    internal func allReminders() -> [Reminder] {
        guard let moc = self.moc else {
            print("couldn't get moc")
            return []
        }
        let request: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: Reminder.Key.intervalCreationDate, ascending: true),
                                   NSSortDescriptor(key: Reminder.Key.fireDate, ascending: true)
        ]
        do {
            let allReminders = try moc.fetch(request)
            let now = Date()
             return allReminders.filter({ (reminder) -> Bool in
                return reminder.fireDate > now
            })
        } catch {
            print(error.localizedDescription)
            return []
        }
        
    }
    
    
    // MARK: - Helper
    
    fileprivate func clearOldReminders() {
        let reminders = allReminders()
        for r in reminders {
            if r.fireDate < Date() {
                remove(reminder: r)
            }
        }
    }
    
    fileprivate func scheduleReminders() {
        
        UIApplication.shared.cancelAllLocalNotifications()
        let orderedReminders = allReminders().sorted { (first, second) -> Bool in
            return first.fireDate < second.fireDate
        }
        guard !orderedReminders.isEmpty else {
            return
        }
        var notifications = [UILocalNotification]()
        for reminder in orderedReminders {
            let n = UILocalNotification()
            n.fireDate = reminder.fireDate
            n.alertBody = reminder.defaultMessage
            notifications.append(n)
        }
        requestPermission()
        UIApplication.shared.scheduledLocalNotifications = notifications
        print("scheduled \(notifications.count) reminders")
        
    }
    
    
    // MARK: - Core Data Stack
    
    
    var storeURL: URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDir = urls.last!
        return docsDir.appendingPathComponent(storeFileName)
    }
    
    lazy var model: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "IntrvalDataModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        var url = self.storeURL
        let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                       NSInferMappingModelAutomaticallyOption: true]
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(String(describing: error)), \(error!.userInfo)")
        }
        
        return coordinator
    }()
    
    lazy var moc: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
}
