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
    
    // MARK: - Properties
    
    // MARK: Singleton Instance
    
    static let main = WatchCommunicator()
    
    // MARK: Private properties
    
    private var dataController: DataController { return  DataController.main }
    
    private let defaults = UserDefaults.standard
    
    private var session: WCSession?
    
    private var dataTransferPending = false
        
    // MARK: - Initializers
    
    private override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dataDidUpdate),
                                               name: .counterDataDidUpdate,
                                               object: nil)
    }
    
    // MARK: - Methods
    
    func activateSession() {
        guard WCSession.isSupported() else { return }
        
        session = WCSession.default
        session?.delegate = self
        session?.activate()
    }
    
    // MARK: WCSession Delegate

    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if dataTransferPending && activationState == .activated {
            initiateTransfer()
        }
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
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
            dataTransferPending = true
            return
        }
        
        dataTransferPending = false
        
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
