//
//  ComplicationData.swift
//  Interval
//
//  Created by Wesley Moore on 4/2/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import Foundation

class DataController {
    
    // MARK: - Types

    private enum Legacy {
        
        static let referenceDate = "referenceDate"
        static let intervalUnit = "intervalUnit"
        static let title = "title"
        static let showSecondUnit = "showSecondUnit"
        
    }
    
    private enum UDKey {
        static let currentInterval = "currentIntervalData"
        static let allIntervals = "watchIntervalData"
    }
    
    // MARK: - Singleton Instance
    
    static let main = DataController()
    
    // MARK: - Properties
    
    weak var delegate: ExtensionDelegate?
    
    var hasData: Bool { return !counters.isEmpty }
    
    var complicationCounter: WatchCounter? {
        get {
            guard let id = UserSettings.idForComplicationCounter else {
                return counters.first
            }
            
            return counter(matching: id) ?? counters.first
        }
        set {
            UserSettings.idForComplicationCounter = newValue?.id
        }
        
    }
    
    private static let defaults = UserDefaults.standard
    
    private var counters = [WatchCounter]()
    
    private var storage = WatchCounterStorage()
    
    // MARK: - Initializers
    
    init() {
        counters = storage.storedCounters()
    }
    
    // MARK: - Methods
    
    func allCounters() -> [WatchCounter]? {
        if counters.isEmpty {
            delegate?.requestCounterDataFromIOS()
            return nil
        }
        
        return counters
    }
    
    func setCounters(_ data: Data) {
        guard let counters = WatchCounterCoder.decode(data) else {
            return
        }
        
        self.counters = counters
        
        updateComplicationCounter()
        
        storage.store(counters)
    }
    
    private func updateComplicationCounter() {
        if let id = UserSettings.idForComplicationCounter,
            let _ = counter(matching: id) {
                return
            }
        
        UserSettings.idForComplicationCounter = nil
    }
    
    private func counter(matching id: UUID) -> WatchCounter? {
        for counter in counters where counter.id == id {
            return counter
        }
        
        return nil
    }
    
}
