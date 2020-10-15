//
//  WatchDataTranslator.swift
//  Interval
//
//  Created by Wesley Moore on 4/2/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import Foundation
import CoreData

open class WatchCounterCoder {

    class func encode(_ counters: [WatchCounter]) -> Data {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(counters)

        return data
    }
    
    class func decode(_ jsonData: Data) -> [WatchCounter]? {
        let decoder = JSONDecoder()
        var counters = [WatchCounter]()
        
        do {
            counters = try decoder.decode([WatchCounter].self, from: jsonData)
        } catch {
            return nil
        }
        
        return counters
    }
    
}
