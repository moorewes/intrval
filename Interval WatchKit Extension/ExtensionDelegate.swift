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
    
    private var dataTransferWaitingForActivation = false
    private var timeOfLastDataTransferRequest: Date?

    // MARK: - Initializers
    
    override init() {
        super.init()
        
        dataController.delegate = self
                
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
        guard isReadyToRequestData() else {
            dataTransferWaitingForActivation = true
            return
        }
        
        dataTransferWaitingForActivation = false
        
        let dataRequest: [String: Any] = [WCKeys.counterDataRequest: true]
        session.sendMessage(dataRequest, replyHandler: handle(_:))
        
        timeOfLastDataTransferRequest = Date()
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
    
    private func isReadyToRequestData() -> Bool {
        if !session.isReachable { return false }
        
        guard let requestTime = timeOfLastDataTransferRequest else { return true }
        
        let maxTimeInterval = TimeInterval(2)
        let elapsedTimeSinceDataRequest = requestTime.distance(to: Date())
        
        if elapsedTimeSinceDataRequest < maxTimeInterval {
            return false
        } else {
            return true
        }
    }
    
}

// MARK: - WCSessionDelegate

extension ExtensionDelegate: WCSessionDelegate {
    
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        if !dataController.hasData || dataTransferWaitingForActivation {
            requestCounterDataFromIOS()
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        handle(userInfo)
    }
    
}
