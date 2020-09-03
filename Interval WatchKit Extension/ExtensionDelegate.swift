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
    
    struct MessageID {
        fileprivate static let allIntervalData = "allIntervalData"
        fileprivate static let initialLaunchDataRequest = "initialLaunch"
    }
    
    var session: WCSession!
    var complicationController: ComplicationController?
    
    // MARK: Lifecycle
    
    func applicationDidFinishLaunching() {
        print("finish launching start")
        // If no data, send request to phone for data
        if ComplicationDataHelper.allIntervals().isEmpty && session.isReachable {
            let message: [String:Any] = [MessageID.initialLaunchDataRequest:true]
            print("sending message for initial request")
            session.sendMessage(message, replyHandler: { (info) in
                print("received response for initial request")
                self.parse(message: info)
                }, errorHandler: { (error) in
                     print(error.localizedDescription)
            })
        }
        print("finish launching over")
        
    }
    override init() {
        print("super init begin")
        super.init()
        print("super init complete")
        ComplicationDataHelper.initializeDefaultsIfNeeded()
        if WCSession.isSupported() {
            session = WCSession.default
            session.delegate = self
            session.activate()
        }
        print("init complete")
        return
    }
    
    
    // MARK: - WCSessionDelegate
    
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let e = error {
            print(e.localizedDescription)
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        print("received user info")
        parse(message: userInfo)
    }
    
    // MARK: - Helper
    
    func updateComplication() {
        let server = CLKComplicationServer.sharedInstance()
        server.activeComplications?.forEach { server.reloadTimeline(for: $0) }
    }
    
    func parse(message: [String:Any]) {
        // Check if all interval data was sent
        if let intervalTransferInfo = message[MessageID.allIntervalData] as? [[String:Any]] {
            print("message parsed successfully, processing now")
            ComplicationDataHelper.saveAll(intervalTransferInfo)
            updateComplication()
        } else {
            print("message was not parsed successfully")
        }
        
    }
    
    
}
