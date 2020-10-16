//
//  DataControllerMock.swift
//  IntervalTests
//
//  Created by Wes Moore on 10/1/20.
//  Copyright © 2020 Wes Moore. All rights reserved.
//

@testable import Interval
import CoreData

class DataControllerMock: DataController {

    override init() {
        super.init()
        
        // Use memory store type for speed while testing
        let persistentStoreDescription = NSPersistentStoreDescription()
        persistentStoreDescription.type = NSInMemoryStoreType

        let container = NSPersistentContainer(name: Counter.modelName)

        container.persistentStoreDescriptions = [persistentStoreDescription]

        container.loadPersistentStores { _, error in
          if let error = error as NSError? {
            fatalError("Unresolved error \(error), \(error.userInfo)")
          }
        }

        self.container = container
    }

}
