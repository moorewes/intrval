//
//  ComplicationController.swift
//  Interval WatchKit Extension
//
//  Created by Wesley Moore on 3/31/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import ClockKit
import WatchKit
import WatchConnectivity

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    var data: (NSDate, NSCalendarUnit)?
//    func measureIntervalWithUnit(unit: NSCalendarUnit) -> String {
//        //let interval = DataMan
//        //let interval = NSCalendar.currentCalendar().component(unit, fromDate: date)
//        //return "\(interval)"
//    }
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.Forward, .Backward])
    }
    
    func getTimelineStartDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehaviorForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.ShowOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    
    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: ((CLKComplicationTimelineEntry?) -> Void)) {
        print("get current timeline entry")
        guard let date = NSUserDefaults.standardUserDefaults().valueForKey(Keys.UD.referenceDate) as? NSDate,
            let unitRaw = NSUserDefaults.standardUserDefaults().valueForKey(Keys.UD.intervalUnit) as? UInt else {
                print("no values in userDefaults")
                return
        }
        let unit = NSCalendarUnit(rawValue: unitRaw)
        let interval = NSCalendar.currentCalendar().components(unit, fromDate: date, toDate: NSDate(), options: NSCalendarOptions()).valueForComponent(unit)
        let digitCount = "\(interval)".characters.count
        switch complication.family {
        case .ModularSmall:
            if digitCount < 4 {
                let template = CLKComplicationTemplateModularSmallSimpleText()
                template.textProvider = CLKRelativeDateTextProvider(date: date, style: .Natural, units: unit)
                let entry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template)
                handler(entry)
            } else {
                let template = CLKComplicationTemplateModularSmallStackText()
                template.line1TextProvider = CLKSimpleTextProvider(text: "\(interval)")
                template.line2TextProvider = CLKSimpleTextProvider(text: "DAYS")
                let entry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template)
                handler(entry)
            }
        case .ModularLarge:
            return
        case .CircularSmall:
            return
        case .UtilitarianSmall:
            return
        case .UtilitarianLarge:
            return
            
        }
        print("got values from standard defaults")
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: - Update Scheduling
    
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        // Call the handler with the date when you would next like to be given the opportunity to update your complication content
        let date = NSDate(timeIntervalSinceNow: 60*60)
        handler(date);
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        handler(nil)
    }
    
}
