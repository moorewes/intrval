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
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.Backward, .Forward])
    }
    
    func getTimelineStartDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        let oneDayPriorInterval: NSTimeInterval = -60*60*24
        let oneDayPriorDate = NSDate(timeInterval: oneDayPriorInterval, sinceDate: NSDate())
        handler(oneDayPriorDate)
    }
    
    func getTimelineEndDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        let oneDayForwardInterval: NSTimeInterval = 60*60*24
        let oneDayForwardDate = NSDate(timeInterval: oneDayForwardInterval, sinceDate: NSDate())
        handler(oneDayForwardDate)
    }
    
    func getPrivacyBehaviorForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.ShowOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: ((CLKComplicationTimelineEntry?) -> Void)) {
        
        // Ensure data exists & retrieve data
        // print("getting current entry")
        guard let date = NSUserDefaults.standardUserDefaults().valueForKey(Keys.UD.referenceDate) as? NSDate,
            let unitRaw = NSUserDefaults.standardUserDefaults().valueForKey(Keys.UD.intervalUnit) as? UInt,
        let titleText = NSUserDefaults.standardUserDefaults().valueForKey(Keys.UD.title) as? String else {
            // print("no values in userDefaults")
            func returnWithTemplate(template: CLKComplicationTemplate) {
                let entry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template)
                handler(entry)
            }
            switch complication.family {
            case .ModularSmall:
                let template = CLKComplicationTemplateModularSmallStackText()
                template.line1TextProvider = CLKSimpleTextProvider(text: "setup")
                template.line2TextProvider = CLKSimpleTextProvider(text: "iOS")
                returnWithTemplate(template)
            case .ModularLarge:
                let template = CLKComplicationTemplateModularLargeStandardBody()
                template.headerTextProvider = CLKSimpleTextProvider(text: "Setup with iOS app")
                returnWithTemplate(template)
            case .CircularSmall:
                let template = CLKComplicationTemplateCircularSmallSimpleText()
                template.textProvider = CLKSimpleTextProvider(text: "setup")
                returnWithTemplate(template)
            case .UtilitarianSmall:
                let template = CLKComplicationTemplateUtilitarianSmallFlat()
                template.textProvider = CLKSimpleTextProvider(text: "setup iOS")
                returnWithTemplate(template)
            case .UtilitarianLarge:
                let template = CLKComplicationTemplateUtilitarianLargeFlat()
                template.textProvider = CLKSimpleTextProvider(text: "setup on iOS")
                returnWithTemplate(template)
            }
            return
        }
        
        
        // Setup
        let showSecondUnit = NSUserDefaults.standardUserDefaults().boolForKey(Keys.UD.showSecondUnit)
        var unit = NSCalendarUnit(rawValue: unitRaw)
        //Note: .Era represents Smart Auto
        if unit == .Era {
            unit = smartAutoUnit(fromDate: date)
        }
        //Build short text for small complications
        let titleLengthLimit = complication.family == .CircularSmall ? 4 : 5
        var titleTextShort = titleText
        if titleTextShort.characters.count > titleLengthLimit {
            let range = titleText.startIndex...titleTextShort.startIndex.advancedBy(titleLengthLimit-1)
            titleTextShort = titleTextShort.substringWithRange(range)
        }
        
        // Build text providers
        let titleTextProvider = CLKSimpleTextProvider(text: titleText, shortText: titleTextShort)
        let numberTextProvider = CLKRelativeDateTextProvider(date: date, style: .Natural, units: unit)
        
        // Configure showing multiple units for larger families
        if showSecondUnit {
            numberTextProvider.calendarUnits = displayUnitsForBaseUnit(unit, date: date, forFamily: complication.family)
        }
        
        // Build entries and execute handler
        switch complication.family {
        case .ModularSmall:
            let template = CLKComplicationTemplateModularSmallStackText()
            template.line1TextProvider = numberTextProvider
            template.line2TextProvider = titleTextProvider
            let entry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template)
            handler(entry)
        case .ModularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = numberTextProvider
            template.body1TextProvider = CLKSimpleTextProvider(text: titleText)
            let entry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template)
            handler(entry)
        case .CircularSmall:
            let template = CLKComplicationTemplateCircularSmallStackText()
            template.line1TextProvider = numberTextProvider
            template.line2TextProvider = titleTextProvider
            let entry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template)
            handler(entry)
        case .UtilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = numberTextProvider
            let entry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template)
            handler(entry)
        case .UtilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider = numberTextProvider
            let entry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template)
            handler(entry)
        }
    }
    
    // MARK: - Update Scheduling
    
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        // Call the handler with the date when you would next like to be given the opportunity to update your complication content
        let date = NSDate(timeIntervalSinceNow: 60*60)
        handler(date);
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        let intervalText = "100 DAYS"
        let shortText = "100D"
        let titleText = "Mom's Birthday"
        let titleTextShort = "BDay"
        switch complication.family {
        case .ModularSmall:
            let template = CLKComplicationTemplateModularSmallStackText()
            let intervalTextProvider = CLKSimpleTextProvider(text: shortText)
            template.line1TextProvider = intervalTextProvider
            template.line2TextProvider = CLKSimpleTextProvider(text: titleTextShort)
            handler(template)
        case .ModularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: intervalText)
            template.body1TextProvider = CLKSimpleTextProvider(text: titleText)
            handler(template)
        case .CircularSmall:
            let template = CLKComplicationTemplateCircularSmallStackText()
            let intervalTextProvider = CLKSimpleTextProvider(text: shortText)
            template.line1TextProvider = intervalTextProvider
            template.line2TextProvider = CLKSimpleTextProvider(text: titleTextShort)
            handler(template)
        case .UtilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            let intervalTextProvider = CLKSimpleTextProvider(text: intervalText)
            template.textProvider = intervalTextProvider
            handler(template)
        case .UtilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            let intervalTextProvider = CLKSimpleTextProvider(text: intervalText)
            template.textProvider = intervalTextProvider
            handler(template)
        }
    }
    
    // MARK: Helper Functions
    func smartAutoUnit(fromDate date: NSDate) -> NSCalendarUnit {
        // print("getting smart auto unit")
        let yearInterval = intervalForUnit(.Year, fromDate: date)
        guard yearInterval < 1 else {
            return .Year
        }
        let monthInterval = intervalForUnit(.Month, fromDate: date)
        guard monthInterval < 1 else {
            return .Month
        }
        let dayInterval = intervalForUnit(.Day, fromDate: date)
        guard dayInterval < 1 else {
            return .Day
        }
        let hourInterval = intervalForUnit(.Hour, fromDate: date)
        guard hourInterval < 1 else {
            return .Hour
        }
        let secondInterval = intervalForUnit(.Second, fromDate: date)
        guard secondInterval < 60 else {
            return .Minute
        }
        return .Second
    }
    func displayUnitsForBaseUnit(unit: NSCalendarUnit, date: NSDate, forFamily family: CLKComplicationFamily) -> NSCalendarUnit {
        var newUnit: NSCalendarUnit?
        // Only allow for certain families
        switch family {
        case .ModularLarge, .UtilitarianLarge, .UtilitarianSmall:
            // Only allow for certain units
            switch unit {
            case NSCalendarUnit.Year: newUnit = .Month
            case NSCalendarUnit.Month: newUnit = .Day
            case NSCalendarUnit.Day: newUnit = .Hour
            case NSCalendarUnit.Hour: newUnit = .Minute
            case NSCalendarUnit.Minute: newUnit = .Second
            case NSCalendarUnit.Second: break
            default: break
            }
        default: break
        }
        let firstUnitInterval = intervalForUnit(unit, fromDate: date)
        guard let secondUnit = newUnit else {
            if firstUnitInterval == 0 {
                return smartAutoUnit(fromDate: date)
            }
            return unit
        }
        var units: NSCalendarUnit = [unit, secondUnit]
        // Test if both units are 0, then use smart unit
        
        let secondUnitInterval = intervalForUnit(secondUnit, fromDate: date)
        if firstUnitInterval == 0 && secondUnitInterval == 0 {
            let smartUnit = smartAutoUnit(fromDate: date)
            units = displayUnitsForBaseUnit(smartUnit, date: date, forFamily: family)
        }
        return units
    }
    func intervalForUnit(unit: NSCalendarUnit, fromDate date: NSDate) -> Int {
        let components = NSCalendar.currentCalendar().components(unit, fromDate: date, toDate: NSDate(), options: NSCalendarOptions())
        let count = components.valueForComponent(unit)
        return abs(count)
    }
}
