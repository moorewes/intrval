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

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    

    
    var session: WCSession!
    var complicationController: ComplicationController?
    func updateComplication() {
        let server = CLKComplicationServer.sharedInstance()
        server.activeComplications?.forEach { server.reloadTimeline(for: $0) }
    }
    func saveData(_ title: String, date: Date) {
        let defaults = UserDefaults.standard
        defaults.setValue(title, forKey: Keys.UD.title)
        defaults.setValue(date, forKey: Keys.UD.referenceDate)
    }
    func initializeDefaultsIfNeeded() {
        let defaults = UserDefaults.standard
        guard defaults.value(forKey: Keys.UD.intervalUnit) as? UInt == nil else {
            // Data already exists
            return
        }
        // Note: .Era represents SmartAuto
        let unit = NSCalendar.Unit.era.rawValue
        defaults.setValue(unit, forKey: Keys.UD.intervalUnit)
        defaults.set(true, forKey: Keys.UD.showSecondUnit)
    }
    
    // MARK: Lifecycle
    
    func applicationDidFinishLaunching() {
        // If no data, send request to phone for data
        if UserDefaults.standard.value(forKey: Keys.UD.referenceDate) as? Date == nil && session.isReachable {
            let message: [String:Any] = ["initialLaunch":true]
            session.sendMessage(message, replyHandler: { (info) in
                let pulledData = ComplicationDataHelper.dataFromUserInfo(info)
                self.saveData(pulledData.title, date: pulledData.date)
                }, errorHandler: { (error) in
                    // print(error.localizedDescription)
            })
        }
        
    }
    override init() {
        super.init()
        initializeDefaultsIfNeeded()
        if WCSession.isSupported() {
            session = WCSession.default()
            session.delegate = self
            session.activate()
        }
        return
    }
    
    
    // MARK: WCSessionDelegate
    
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
//        if let e = error {
//            print(e.localizedDescription)
//        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        let pulledData = ComplicationDataHelper.dataFromUserInfo(userInfo)
        UserDefaults.standard.setValue(pulledData.date, forKey: Keys.UD.referenceDate)
        UserDefaults.standard.setValue(pulledData.title, forKey: Keys.UD.title)
        updateComplication()
    }
    
    
}
