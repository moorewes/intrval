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
    static let watchIntervalDataUpdated = Notification.Name(rawValue: "watchIntervalDataUpdated")
}

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
    
    // MARK: Lifecycle
    
    func applicationDidFinishLaunching() {

        if dataController.counters.isEmpty && session.isReachable {
            let message: [String: Any] = [WCKeys.counterDataRequest: true]
            
            session.sendMessage(message, replyHandler: { (reply) in
                self.handle(reply)
                }, errorHandler: { (error) in
                     print(error.localizedDescription)
            })
        }
    }

   
    
    // MARK: - Convenience Methods
    
    func updateComplication() {
        let server = CLKComplicationServer.sharedInstance()
        server.activeComplications?.forEach { server.reloadTimeline(for: $0) }
    }
    
    private func handle(_ message: [String: Any]) {
        if let counterData = message[WCKeys.counterData] as? Data {
            dataController.setCounters(counterData)
            updateComplication()
        }
    }
    
}

// MARK: - WCSessionDelegate

extension ExtensionDelegate: WCSessionDelegate {

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let e = error {
            print(e.localizedDescription)
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        handle(userInfo)
    }
    
}
