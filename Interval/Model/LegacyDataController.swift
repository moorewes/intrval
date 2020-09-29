//
//  DataStorageHelper.swift
//  Interval
//
//  Created by Wesley Moore on 4/1/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import Foundation
import WatchConnectivity

open class LegacyDataController: NSObject, WCSessionDelegate {
    
    struct Keys {
        static let intervalData = "intervalData"
        public static let referenceDate = "referenceDate"
        public static let intervalUnit = "intervalUnit"
        public static let includeTime = "includeTime"
        public static let title = "title"
        public static let hasSaved = "hasSaved"
        public static let openCount = "openCount"
        public static let rateStatus = "rateStatus"
        private init() {}
    }
    
    static let main = LegacyDataController()
    
    fileprivate let defaults = UserDefaults.standard
    
    var session: WCSession?
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
//            print("session watch state(paired): ", session!.isPaired)
//            print("session watch state(appInstalled): ", session!.isWatchAppInstalled)
//            print("session watch state(complicationEnabled): ", session!.isComplicationEnabled)
//            print("WCSession activated iOS")
//            print("outstanding transfer count: \(WCSession.default().outstandingFileTransfers.count)")
        }
    }
    
    public func transferDataToWatch() {
        guard let _ = session else {
            print("Tried to transfer data to watch but no session exists")
            return
        }
        if #available(iOS 9.3, *) {
            guard session?.activationState == .activated else {
                print("Tried to transfer data to watch but session is not activated")
                return
            }
        }
        let intervals = allIntervals()
        let data = ComplicationDataHelper.userInfo(for: intervals)
        WCSession.default.transferCurrentComplicationUserInfo(data)
    }
    
    // MARK: - Legacy Data Migration
    
    internal func legacyCounter() -> [(title: String, date: Date, includeTime: Bool)]? {
        
        return nil
        
    }
    
    // MARK: - Legacy To Remain (Prev)
    
    open func transferLegacyData() {
        guard let date = defaults.value(forKey: Keys.referenceDate) as? Date,
            let unitRaw = defaults.value(forKey: Keys.intervalUnit) as? UInt,
            let includeTime = defaults.value(forKey: Keys.includeTime) as? Bool,
            let description = defaults.value(forKey: Keys.title) as? String else {
                return
        }
        let interval = Interval(date: date, unit: NSCalendar.Unit(rawValue: unitRaw), includeTime: includeTime, description: description, creationDate: Date())
        store(interval: interval)
        // Delete legacy data
        defaults.removeObject(forKey: Keys.referenceDate)
        defaults.removeObject(forKey: Keys.intervalUnit)
        defaults.removeObject(forKey: Keys.includeTime)
        defaults.removeObject(forKey: Keys.title)
        print("successfully transfered legacy data")
    }
    
    open func clearAccidentIntervals() {
        let intervals = allIntervals()
        for interval in intervals {
            if interval.creationDate.timeIntervalSinceNow > -5 && interval.description == "" {
                remove(interval: interval, from: intervals)
            }
        }
    }
    
    open func allIntervals() -> [Interval] {
        var result = [Interval]()
        guard let data = defaults.object(forKey: Keys.intervalData) as? [[String: AnyObject]] else {
            print("no data to fetch")
            return result
        }
        for item in data {
            let interval = Interval(dict: item)
            result.append(interval)
        }
        print("fetched all data")
        return result
    }
    open func dataObject() -> [[String:AnyObject]] {
        guard let data = defaults.object(forKey: Keys.intervalData) as? [[String: AnyObject]] else {
            return []
        }
        return data
    }
    
    open func store(interval: Interval) {
        var intervals = [[String:AnyObject]]()
        if let data = defaults.object(forKey: Keys.intervalData) as? [[String: AnyObject]] {
            intervals = data
        }
        intervals.append(interval.asDict())
        defaults.set(intervals, forKey: Keys.intervalData)
        transferDataToWatch()
    }
    
    
    open func update(interval: Interval) {
        let intervals = allIntervals()
        for (index, item) in intervals.enumerated() {
            if item.creationDate == interval.creationDate {
                var data = dataObject()
                data[index] = interval.asDict()
                defaults.set(data, forKey: Keys.intervalData)
                print("updated interval")
                transferDataToWatch()
            }
        }
    }
    
    open func remove(interval: Interval, from intervals: [Interval]? = nil) {
        let allntervals = intervals ?? allIntervals()
        for (index, item) in allntervals.enumerated() {
            if item.creationDate == interval.creationDate {
                var data = dataObject()
                data.remove(at: index)
                defaults.set(data, forKey: Keys.intervalData)
                print("deleted interval")
                transferDataToWatch()
            }
        }
    }
    
    open func interval(withCreationDate creationDate: Date) -> Interval? {
        for interval in allIntervals() {
            if interval.creationDate == creationDate {
                return interval
            }
        }
        return nil
    }
    
    // MARK: - Rating Status Methods
    
    public func update(rateStatus: RateAlertStatus) {
        let value = rateStatus.rawValue
        defaults.set(value, forKey: Keys.rateStatus)
        
    }
    
    func rateStatus() -> RateAlertStatus {
        let rawValue = defaults.integer(forKey: Keys.rateStatus)
        return RateAlertStatus(rawValue: rawValue)
    }
    
    open func incrementAppOpenCount() {
        var count = defaults.integer(forKey: Keys.openCount)
        count += 1
        defaults.set(count, forKey: Keys.openCount)
    }
    
    func openCount() -> Int {
        return defaults.integer(forKey: Keys.openCount)
    }
    
    func hasSaved() -> Bool {
        return defaults.bool(forKey: Keys.hasSaved)
    }
    
    // MARK: WCSession Delegate
    
    @available(iOS 9.3, *)
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("session activated")
        if let e = error {
            print(e.localizedDescription)
        }
        //updateStatusLabel()
    }
    public func sessionReachabilityDidChange(_ session: WCSession) {
        //updateStatusLabel()
    }
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("received message")
        if let _ = message["initialLaunch"] as? Bool {
            let data = allIntervals()
            let reply = ComplicationDataHelper.userInfo(for: data)
            print("sent message back")
            replyHandler(reply)
        }
    }
    public func sessionDidBecomeInactive(_ session: WCSession) {
        //updateStatusLabel()
        print("sessionDidBecomeInactive")
    }
    public func sessionWatchStateDidChange(_ session: WCSession) {
        //updateStatusLabel()
        print("session watch state(paired) changed: ", session.isPaired)
        print("session watch state(appInstalled) changed: ", session.isWatchAppInstalled)
        print("session watch state changed(complicationEnabled): ", session.isComplicationEnabled)
    }
    public func sessionDidDeactivate(_ session: WCSession) {
        print("deactivate session")
        //updateStatusLabel()
    }
    
}

//enum RateStatus: Int {
//    case UserHasAccepted = 1, UserChoseLater, UserChoseNever
//}
