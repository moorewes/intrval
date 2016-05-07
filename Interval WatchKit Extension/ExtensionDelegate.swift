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
        server.activeComplications?.forEach { server.reloadTimelineForComplication($0) }
    }
    func saveData(title: String, date: NSDate) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(title, forKey: Keys.UD.title)
        defaults.setValue(date, forKey: Keys.UD.referenceDate)
    }
    func initializeDefaultsIfNeeded() {
        let defaults = NSUserDefaults.standardUserDefaults()
        guard defaults.valueForKey(Keys.UD.intervalUnit) as? UInt == nil else {
            // Data already exists
            return
        }
        // Note: .Era represents SmartAuto
        let unit = NSCalendarUnit.Era.rawValue
        defaults.setValue(unit, forKey: Keys.UD.intervalUnit)
        defaults.setBool(true, forKey: Keys.UD.showSecondUnit)
    }
    
    // MARK: Lifecycle
    
    func applicationDidFinishLaunching() {
        // If no data, send request to phone for data
        if NSUserDefaults.standardUserDefaults().valueForKey(Keys.UD.referenceDate) as? NSDate == nil && session.reachable {
            let message: [String:AnyObject] = ["initialLaunch":true]
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
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        return
    }
    
    
    // MARK: WCSessionDelegate
    
    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        let pulledData = ComplicationDataHelper.dataFromUserInfo(userInfo)
        NSUserDefaults.standardUserDefaults().setValue(pulledData.date, forKey: Keys.UD.referenceDate)
        NSUserDefaults.standardUserDefaults().setValue(pulledData.title, forKey: Keys.UD.title)
        updateComplication()
    }
    
    
}
