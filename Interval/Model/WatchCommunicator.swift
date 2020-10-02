//
//  DataStorageHelper.swift
//  Interval
//
//  Created by Wesley Moore on 4/1/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import Foundation
import WatchConnectivity

open class WatchCommunicator: NSObject, WCSessionDelegate {
    
    // MARK: - Types
    
    private enum Keys {
        static let intervalData = "intervalData"
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
    
    private let defaults = UserDefaults.standard
    
    private var session: WCSession?
    
    // MARK: - Initializers
    
    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
//            print("session watch state(paired): ", session!.isPaired)
//            print("session watch state(appInstalled): ", session!.isWatchAppInstalled)
//            print("session watch state(complicationEnabled): ", session!.isComplicationEnabled)
//            print("WCSession activated iOS")
//            print("outstanding transfer count: \(WCSession.default().outstandingFileTransfers.count)")
        }
    }
    
    // MARK: - Methods
    
    // MARK: Internal Methods
    
    func transferDataToWatch() {
        guard session?.activationState == .activated else {
            print("Tried to transfer data to watch but session is not activated")
            return
        }
        let data = WatchDataTranslator.data()
        WCSession.default.transferCurrentComplicationUserInfo(data)
    }
    
    // MARK: WCSession Delegate

    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("session activated")
        if let e = error {
            print(e.localizedDescription)
        }
    }
    
    public func sessionReachabilityDidChange(_ session: WCSession) {
        //updateStatusLabel()
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("received message")
        if let _ = message["initialLaunch"] as? Bool {
            // TODO
            //let data = DataController.main.counters
            //let reply = WatchDataTranslator.data(for: counters)
            print("sent message back")
            //replyHandler(reply)
        }
    }
    
    public func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive")
    }
    
    public func sessionWatchStateDidChange(_ session: WCSession) {
        print("session watch state(paired) changed: ", session.isPaired)
        print("session watch state(appInstalled) changed: ", session.isWatchAppInstalled)
        print("session watch state changed(complicationEnabled): ", session.isComplicationEnabled)
    }
    
    public func sessionDidDeactivate(_ session: WCSession) {
        print("session deactivated")
    }
    
}
