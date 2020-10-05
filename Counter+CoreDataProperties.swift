//
//  Counter+CoreDataProperties.swift
//  Interval
//
//  Created by Wes Moore on 10/5/20.
//  Copyright © 2020 Wes Moore. All rights reserved.
//
//

import Foundation
import CoreData


extension Counter {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Counter> {
        return NSFetchRequest<Counter>(entityName: "Counter")
    }

    @NSManaged public var date: Date
    @NSManaged public var includeTime: Bool
    @NSManaged public var title: String
    @NSManaged public var id: UUID

}
