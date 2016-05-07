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
    //var complicationData: (date: NSDate, unit: NSCalendarUnit, title: String)?
    var complicationController: ComplicationController?
    func updateComplication() {
        let server = CLKComplicationServer.sharedInstance()
        server.activeComplications?.forEach { server.reloadTimelineForComplication($0) }
    }
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        print("applicationDidFinishLaunching")
        // If no data, send request to phone for data
        if NSUserDefaults.standardUserDefaults().valueForKey(Keys.UD.referenceDate) as? NSDate == nil && session.reachable {
            print("sending inital data request to iOS")
            let message: [String:AnyObject] = ["initialLaunch":true]
            session.sendMessage(message, replyHandler: { (info) in
                print("received reply to initial data request to iOS")
                let pulledData = ComplicationDataHelper.dataFromUserInfo(info)
                self.saveData(pulledData.title, date: pulledData.date)
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
        initializeDefaultsIfNeeded()
        if WCSession.isSupported() {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
            print("WCSession activated watchOS")
        }
        return
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
    // MARK: WCSessionDelegate
    
    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        print("received userInfo on watch extension")
        let pulledData = ComplicationDataHelper.dataFromUserInfo(userInfo)
        NSUserDefaults.standardUserDefaults().setValue(pulledData.date, forKey: Keys.UD.referenceDate)
        NSUserDefaults.standardUserDefaults().setValue(pulledData.title, forKey: Keys.UD.title)
        updateComplication()
    }
    
    
}
