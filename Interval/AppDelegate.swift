//
//  AppDelegate.swift
//  Interval
//
//  Created by Wesley Moore on 3/31/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import UIKit
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    //var session: WCSession?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        LegacyDataController.main.transferLegacyData()
        
        if let customFont = UIFont(name: "Futura-CondensedMedium", size: 20.0) {
            UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: customFont], for: .normal)
            UINavigationBar.appearance().tintColor = UIColor.init(named: "NavBarItems")
        }
        
        return true
    }
}

