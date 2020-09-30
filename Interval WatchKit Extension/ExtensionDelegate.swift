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

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    
    private enum MessageKey {
        static let counterData = "allIntervalData"
        static let dataRequest = "initialLaunch"
    }
    
    var session: WCSession!
    var complicationController: ComplicationController?
    
    // MARK: - Initializers
    
    override init() {
        super.init()
        
        ComplicationDataHelper.initializeDefaultsIfNeeded()
        
        if WCSession.isSupported() {
            session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    // MARK: Lifecycle
    
    func applicationDidFinishLaunching() {

        if ComplicationDataHelper.allIntervals().isEmpty && session.isReachable {
            let message: [String: Any] = [MessageKey.dataRequest: true]
            print("sending message for initial request")
            
            session.sendMessage(message, replyHandler: { (reply) in
                print("received response for initial request")
                self.handle(reply)
                }, errorHandler: { (error) in
                     print(error.localizedDescription)
            })
        }
        print("finished launching extension")
        
    }

    // MARK: - WCSessionDelegate
    
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let e = error {
            print(e.localizedDescription)
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        print("received user info")
        handle(userInfo)
    }
    
    // MARK: - Convenience Methods
    
    func updateComplication() {
        let server = CLKComplicationServer.sharedInstance()
        server.activeComplications?.forEach { server.reloadTimeline(for: $0) }
    }
    
    private func handle(_ message: [String: Any]) {
        // Check if all interval data was sent
        if let intervalTransferInfo = message[MessageKey.counterData] as? [[String: Any]] {
            print("message parsed successfully, processing now")
            ComplicationDataHelper.importTransferData(intervalTransferInfo)
            updateComplication()
        } else {
            print("message was not parsed successfully")
        }
        
    }
    
    
}
