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
    var dataController: DataController { return DataController.main }
    
    private var dataTransferPending = false

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
    
    func requestCounterDataFromIOS() {
        guard session.isReachable else {
            dataTransferPending = true
            return
        }
        
        dataTransferPending = false
        
        let dataRequest: [String: Any] = [WCKeys.counterDataRequest: true]
        session.sendMessage(dataRequest, replyHandler: nil)
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
    
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        if dataController.counters.isEmpty || dataTransferPending {
            requestCounterDataFromIOS()
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        handle(userInfo)
    }
    
}
