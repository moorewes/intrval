//
//  Reminder+CoreDataProperties.swift
//  Interval
//
//  Created by Wesley Moore on 8/4/17.
//  Copyright © 2017 Wes Moore. All rights reserved.
//

import Foundation
import CoreData


extension Reminder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reminder> {
        return NSFetchRequest<Reminder>(entityName: "Reminder")
    }

    @NSManaged public var fireDate: Date
    @NSManaged public var message: String
    @NSManaged public var intervalCreationDate: Date
    
    

}
