//
//  WatchCounterStorage.swift
//  Interval WatchKit Extension
//
//  Created by Wes Moore on 10/7/20.
//  Copyright © 2020 Wes Moore. All rights reserved.
//

import Foundation

struct WatchCounterStorage {
    
    private enum Keys {
        static let allCounters = "allCounters"
    }
    
    private let defaults = UserDefaults.standard
    
    func storedCounters() -> [WatchCounter] {
        guard let data = defaults.data(forKey: Keys.allCounters),
              let counters = WatchCounterCoder.decode(data) else {
            return []
        }
        
        return counters
    }
    
    func store(_ counters: [WatchCounter]) {
        let data = counters.isEmpty ? nil : WatchCounterCoder.encode(counters)
        defaults.setValue(data, forKey: Keys.allCounters)
    }
    
}
