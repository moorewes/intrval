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
    var complicationData: (date: NSDate, unit: NSCalendarUnit)?
    var complicationController: ComplicationController?

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        print("applicationDidFinishLaunching")
        if session.reachable {
            print("sending inital data request to ios")
            let message: [String:AnyObject] = ["initialLaunch":true]
            session.sendMessage(message, replyHandler: { (info) in
                self.complicationData = ComplicationDataHelper.dataFromUserInfo(info)
                }, errorHandler: { (error) in
                    print(error.localizedDescription)
            })
        }
    }

    func applicationDidBecomeActive() {
        print("applicationDidBecomeActive")
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        print("applicationWillResignActive")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
    override init() {
        super.init()
        print("init")
        if WCSession.isSupported() {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
            print("WCSession activated watchOS")
        }
        let defaults = NSUserDefaults(suiteName: Keys.UD.appGroup)
        guard let date = defaults?.valueForKey(Keys.UD.referenceDate) as? NSDate,
        let unitRaw = defaults?.valueForKey(Keys.UD.intervalUnit) as? UInt else {
            print("unable to load app group data")
            if let date = NSUserDefaults.standardUserDefaults().valueForKey(Keys.UD.referenceDate) as? NSDate,
                let unit = NSUserDefaults.standardUserDefaults().valueForKey(Keys.UD.intervalUnit) as? UInt {
                complicationData = (date, NSCalendarUnit(rawValue: unit))
            }
            return
        }
        complicationData = (date, NSCalendarUnit(rawValue: unitRaw))
        print("loaded app group data")
        
        
        
    }
    
    // MARK: WCSessionDelegate
    
    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        print("received userInfo on watch extension")
        complicationData = ComplicationDataHelper.dataFromUserInfo(userInfo)
        NSUserDefaults.standardUserDefaults().setValue(complicationData!.date, forKey: Keys.UD.referenceDate)
        NSUserDefaults.standardUserDefaults().setValue(complicationData!.unit.rawValue, forKey: Keys.UD.intervalUnit)
        //guard let _ = complicationController else { return }
        let server = CLKComplicationServer.sharedInstance()
        server.activeComplications?.forEach { server.reloadTimelineForComplication($0) }
    }
    
    
}
