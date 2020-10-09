//
//  DataStorageHelper.swift
//  Interval
//
//  Created by Wesley Moore on 4/1/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import Foundation
import WatchConnectivity
import CoreData

class WatchCommunicator: NSObject, WCSessionDelegate {
    
    // MARK: - Types
    
    private enum Keys {
        public static let referenceDate = "referenceDate"
        public static let intervalUnit = "intervalUnit"
        public static let includeTime = "includeTime"
        public static let title = "title"
        public static let hasSaved = "hasSaved"
        public static let openCount = "openCount"
        public static let rateStatus = "rateStatus"
    }
    
    // MARK: - Properties
    
    // MARK: Singleton Instance
    
    static let main = WatchCommunicator()
    
    // MARK: Private properties
    
    private let dataController = DataController.main
    
    private let defaults = UserDefaults.standard
    
    private var session: WCSession?
    
    // MARK: - Initializers
    
    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dataDidUpdate),
                                               name: .NSManagedObjectContextDidSave,
                                               object: nil)
    }
    
    // MARK: - Methods
    
    // MARK: WCSession Delegate

    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let e = error {
            print(e.localizedDescription)
        }
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let _ = message[WCKeys.counterDataRequest] as? Bool {
            initiateTransfer()
        }
    }
    
    public func sessionDidDeactivate(_ session: WCSession) {
        self.session = WCSession.default
        session.activate()
    }
    
    public func sessionDidBecomeInactive(_ session: WCSession) {}
    
    // MARK: Helper Methods
    
    @objc
    private func dataDidUpdate() {
        initiateTransfer()
    }
    
    private func initiateTransfer() {
        guard session?.activationState == .activated else {
            return
        }
        
        dataController.container.performBackgroundTask { (moc) in
            let counters = self.fetchCounters(in: moc)
            let watchCounters = counters.map { $0.asWatchCounter() }
            let data = WatchCounterCoder.encode(watchCounters)
            let userInfo = [WCKeys.counterData: data]
            
            WCSession.default.transferCurrentComplicationUserInfo(userInfo)
        }
    }
    
    private func fetchCounters(in moc: NSManagedObjectContext) -> [Counter] {
        let fetchRequest: NSFetchRequest<Counter> = Counter.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        var counters = [Counter]()
        do {
            counters = try moc.fetch(fetchRequest)
        } catch {
            return []
        }
        return counters
    }
    
}
