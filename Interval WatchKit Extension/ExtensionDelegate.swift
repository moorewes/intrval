//
//  ExtensionDelegate.swift
//  Interval WatchKit Extension
//
//  Created by Wesley Moore on 3/31/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import ClockKit
import WatchKit
import WatchConnectivity

extension Notification.Name {
    
    static let counterDataDidUpdate = Notification.Name(rawValue: "counterDataDidUpdate")
    
}

// MARK: -

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    var session: WCSession!
    var complicationController: ComplicationController?
    var dataController = DataController.main

    // MARK: - Initializers
    
    override init() {
        super.init()
                
        if WCSession.isSupported() {
            session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    // MARK: - Convenience Methods
    
    func updateComplication() {
        let server = CLKComplicationServer.sharedInstance()
        server.activeComplications?.forEach { server.reloadTimeline(for: $0) }
    }
    
    private func handle(_ message: [String: Any]) {
        if let counterData = message[WCKeys.counterData] as? Data {
            handleCounterDataUpdate(data: counterData)
        }
    }
    
    private func handleCounterDataUpdate(data: Data) {
        dataController.setCounters(data)
        
        updateComplication()
        
        NotificationCenter.default.post(name: .counterDataDidUpdate, object: nil)
    }
    
}

// MARK: - WCSessionDelegate

extension ExtensionDelegate: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Request data if there is no local data
        if dataController.counters.isEmpty && session.isReachable {
            let dataRequest: [String: Any] = [WCKeys.counterDataRequest: true]
            session.sendMessage(dataRequest, replyHandler: nil)
        }
        
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        handle(userInfo)
    }
    
}
