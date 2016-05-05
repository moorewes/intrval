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
    
    var data: (date: NSDate, unit: NSCalendarUnit, title: String)?
    let utilitarianSmallLimitForAutoTimeTravel = 1000000
    let utilitarianLargeLimitForAutoTimeTravel: Int? = nil
    let modularSmallLimitForAutoTimeTravel = 1000
    let modularLargeLimitForAutoTimeTravel: Int? = nil
    let circularSmallLimitForAutoTimeTravel = 1000
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
        guard let date = NSUserDefaults.standardUserDefaults().valueForKey(Keys.UD.referenceDate) as? NSDate,
            let unitRaw = NSUserDefaults.standardUserDefaults().valueForKey(Keys.UD.intervalUnit) as? UInt,
            let titleText = NSUserDefaults.standardUserDefaults().valueForKey(Keys.UD.description) as? String  else {
                print("no values in userDefaults")
                handler([])
                return
        }
        let unit = NSCalendarUnit(rawValue: unitRaw)
        data = (date, unit, titleText)
        if supportsTimeTravelForFamily(complication.family) {
            handler([.Backward, .Forward])
        } else {
            handler([.None])
        }
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
        print("starting")
        guard let date = NSUserDefaults.standardUserDefaults().valueForKey(Keys.UD.referenceDate) as? NSDate,
            let unitRaw = NSUserDefaults.standardUserDefaults().valueForKey(Keys.UD.intervalUnit) as? UInt,
        let titleText = NSUserDefaults.standardUserDefaults().valueForKey(Keys.UD.description) as? String else {
            print("no values in userDefaults")
            func returnWithTemplate(template: CLKComplicationTemplate) {
                let entry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template)
                handler(entry)
            }
            switch complication.family {
            case .ModularSmall:
                let template = CLKComplicationTemplateModularSmallStackText()
                template.line1TextProvider = CLKSimpleTextProvider(text: "setup")
                template.line2TextProvider = CLKSimpleTextProvider(text: "on iOS")
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
        let unit = NSCalendarUnit(rawValue: unitRaw)
        data = (date, unit, titleText)
        let interval = intervalForUnit(unit, fromDate: date)
        let timeRelation = interval > 0 ? "since" : "until"
        let intervalAbsolute = abs(interval)
        let fullText = "\(intervalAbsolute)"
        let unitStringShort = shortUnitStringForUnit(unit, count: intervalAbsolute)
        // Create Shortened Text
        var titleTextShort = titleText
        let titleLengthLimit = complication.family == .CircularSmall ? 4 : 5
        if titleTextShort.characters.count > titleLengthLimit {
            let range = titleText.startIndex...titleTextShort.startIndex.advancedBy(titleLengthLimit-1)
            titleTextShort = titleTextShort.substringWithRange(range)
        }
        let titleTextProvider = CLKSimpleTextProvider(text: titleText, shortText: titleTextShort)
        var shortText = fullText
        let digitCount = "\(intervalAbsolute)".characters.count
        var tenthsDigit = 0
        var multiplier = ""
        if digitCount > 6 { // Add m for million if needed
            let range = shortText.startIndex.advancedBy(digitCount-6)..<shortText.endIndex
            let removed = shortText.substringWithRange(range)
            print(removed)
            //Get digit for tenths place
            guard let firstDigit = Int(String(removed[removed.startIndex])) else {
                print("couldn't make ints out of strings")
                return
            }
            tenthsDigit = firstDigit
            shortText.removeRange(range)
            multiplier = "m"
            
        } else if digitCount > 3 { // Add k for thousand if needed
            let range = shortText.startIndex.advancedBy(digitCount-3)..<shortText.endIndex
            let removed = shortText.substringWithRange(range)
            print(removed)
            //Get digit for tenths place
            guard let firstDigit = Int(String(removed[removed.startIndex])) else {
                print("couldn't make ints out of strings")
                return
            }
            tenthsDigit = firstDigit
            shortText.removeRange(range)
            multiplier = "k"
        }
        if let limit = autoTimeTravelLimitForFamily(complication.family) where shortText.characters.count < limit - 1 {
            shortText += "."
            shortText += "\(tenthsDigit)"
        }
        shortText += multiplier
        // Setup Text Providers, allow minute to be relative if less than x minutes
        var numberTextProvider: CLKTextProvider!
        let timeTravelEnabled = supportsTimeTravelForFamily(complication.family)
        if timeTravelEnabled  {
            numberTextProvider = CLKRelativeDateTextProvider(date: date, style: .Natural, units: unit)
        } else {
            numberTextProvider = CLKSimpleTextProvider(text: fullText, shortText: shortText)
        }
        
        switch complication.family {
        case .ModularSmall:
            if timeTravelEnabled {
                let template = CLKComplicationTemplateModularSmallStackText()
                template.line1TextProvider = numberTextProvider
                template.line2TextProvider = titleTextProvider
                let entry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template)
                handler(entry)
            } else {
                let template = CLKComplicationTemplateModularSmallStackText()
                template.line1TextProvider = numberTextProvider
                template.line2TextProvider = CLKSimpleTextProvider(text: unitStringShort)
                let entry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template)
                handler(entry)
            }
        case .ModularLarge:
            if timeTravelEnabled {
                let template = CLKComplicationTemplateModularLargeStandardBody()
                template.headerTextProvider = numberTextProvider
                let middleText = timeRelation
                template.body1TextProvider = CLKSimpleTextProvider(text: middleText)
                template.body2TextProvider = CLKSimpleTextProvider(text: titleText)
                let entry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template)
                handler(entry)
            } else {
                let template = CLKComplicationTemplateModularLargeStandardBody()
                template.headerTextProvider = numberTextProvider
                let middleText = unitStringShort + " " + timeRelation
                template.body1TextProvider = CLKSimpleTextProvider(text: middleText)
                template.body2TextProvider = CLKSimpleTextProvider(text: titleText)
                let entry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template)
                handler(entry)
            }
            
        case .CircularSmall:
            if timeTravelEnabled {
                let template = CLKComplicationTemplateCircularSmallStackText()
                template.line1TextProvider = numberTextProvider
                template.line2TextProvider = titleTextProvider
                let entry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template)
                handler(entry)
            } else {
                let template = CLKComplicationTemplateCircularSmallStackText()
                template.line1TextProvider = numberTextProvider
                template.line2TextProvider = CLKSimpleTextProvider(text: unitStringShort)
                let entry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template)
                handler(entry)
            }
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
        print("finished")
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: ([CLKComplicationTimelineEntry]?) -> Void) {
        
    }
    // MARK: - Update Scheduling
    
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        // Call the handler with the date when you would next like to be given the opportunity to update your complication content
        let date = NSDate(timeIntervalSinceNow: 60*60)
        handler(date);
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        let text = "100"
        let unitText = "DAYS"
        let timeRelation = "UNTIL"
        let titleText = "I GO TO ICELAND"
        switch complication.family {
        case .ModularSmall:
            let template = CLKComplicationTemplateModularSmallStackText()
            let intervalTextProvider = CLKSimpleTextProvider(text: text)
            template.line1TextProvider = intervalTextProvider
            template.line2TextProvider = CLKSimpleTextProvider(text: unitText)
            handler(template)
        case .ModularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: text)
            let middleText = unitText + " " + timeRelation
            template.body1TextProvider = CLKSimpleTextProvider(text: middleText)
            template.body2TextProvider = CLKSimpleTextProvider(text: titleText)
            handler(template)
        case .CircularSmall:
            let template = CLKComplicationTemplateCircularSmallStackText()
            let intervalTextProvider = CLKSimpleTextProvider(text: text)
            template.line1TextProvider = intervalTextProvider
            template.line2TextProvider = CLKSimpleTextProvider(text: unitText)
            handler(template)
        case .UtilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            let intervalTextProvider = CLKSimpleTextProvider(text: text + " " + unitText)
            template.textProvider = intervalTextProvider
            handler(template)
        case .UtilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            let intervalTextProvider = CLKSimpleTextProvider(text: text + " " + unitText)
            template.textProvider = intervalTextProvider
            handler(template)
            
        }
    }
    
    // MARK: Helper Functions
    
    func intervalForUnit(unit: NSCalendarUnit, fromDate date: NSDate) -> Int {
        let components = NSCalendar.currentCalendar().components(unit, fromDate: date, toDate: NSDate(), options: NSCalendarOptions())
        let count = components.valueForComponent(unit)
        return count
    }
    func shortUnitStringForUnit(unit: NSCalendarUnit, count: Int) -> String {
        var answer: String
        switch unit {
        case NSCalendarUnit.Day: answer = "DAY"
        case NSCalendarUnit.WeekOfYear: answer = "WK"
        case NSCalendarUnit.Month: answer = "MON"
        case NSCalendarUnit.Year: answer = "YR"
        case NSCalendarUnit.Minute: answer = "MIN"
        case NSCalendarUnit.Hour: answer = "HR"
        default: answer = "DAY"
        }
        if count != 1 {
            answer += "S"
        }
        return answer
    }
    func isWithinTimeTravelLimitForMinuteCount(count: Int) -> Bool {
        var answer = false
        if count < 1000 {
            answer = true
        }
        return answer
    }
    func supportsTimeTravelForFamily(family: CLKComplicationFamily) -> Bool {
        //Setup
        guard let data = data else {
            return false
        }
        let interval = abs(intervalForUnit(data.unit, fromDate: data.date))
        let numberLimit = autoTimeTravelLimitForFamily(family)
        // Test
        // If no limit then it is supported
        guard let _ = numberLimit else {
            return true
        }
        // If limit then test if within
        if interval < numberLimit {
            return true
        }
        return false
    }
    func autoTimeTravelLimitForFamily(family: CLKComplicationFamily) -> Int? {
        var limit: Int?
        switch family {
        case .UtilitarianLarge: limit = utilitarianLargeLimitForAutoTimeTravel
        case .UtilitarianSmall: limit = utilitarianSmallLimitForAutoTimeTravel
        case .ModularLarge: limit = modularLargeLimitForAutoTimeTravel
        case .ModularSmall: limit = modularSmallLimitForAutoTimeTravel
        case .CircularSmall: limit = circularSmallLimitForAutoTimeTravel
        }
        return limit
    }
}
