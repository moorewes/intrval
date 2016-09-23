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
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.backward, .forward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        let oneDayPriorInterval: TimeInterval = -60*60*24
        let oneDayPriorDate = Date(timeInterval: oneDayPriorInterval, since: Date())
        handler(oneDayPriorDate)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        let oneDayForwardInterval: TimeInterval = 60*60*24
        let oneDayForwardDate = Date(timeInterval: oneDayForwardInterval, since: Date())
        handler(oneDayForwardDate)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: (@escaping (CLKComplicationTimelineEntry?) -> Void)) {
        
        // Ensure data exists & retrieve data
        // print("getting current entry")
        guard let date = UserDefaults.standard.value(forKey: Keys.UD.referenceDate) as? Date,
            let unitRaw = UserDefaults.standard.value(forKey: Keys.UD.intervalUnit) as? UInt,
        let titleText = UserDefaults.standard.value(forKey: Keys.UD.title) as? String else {
            // print("no values in userDefaults")
            func returnWithTemplate(_ template: CLKComplicationTemplate) {
                let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
                handler(entry)
            }
            switch complication.family {
            case .modularSmall:
                let template = CLKComplicationTemplateModularSmallStackText()
                template.line1TextProvider = CLKSimpleTextProvider(text: "setup")
                template.line2TextProvider = CLKSimpleTextProvider(text: "iOS")
                returnWithTemplate(template)
            case .modularLarge:
                let template = CLKComplicationTemplateModularLargeStandardBody()
                template.headerTextProvider = CLKSimpleTextProvider(text: "Setup with iOS app")
                template.body1TextProvider = CLKSimpleTextProvider(text: "")
                returnWithTemplate(template)
            case .circularSmall:
                let template = CLKComplicationTemplateCircularSmallSimpleText()
                template.textProvider = CLKSimpleTextProvider(text: "setup")
                returnWithTemplate(template)
            case .utilitarianSmall:
                let template = CLKComplicationTemplateUtilitarianSmallFlat()
                template.textProvider = CLKSimpleTextProvider(text: "setup iOS")
                returnWithTemplate(template)
            case .utilitarianLarge:
                let template = CLKComplicationTemplateUtilitarianLargeFlat()
                template.textProvider = CLKSimpleTextProvider(text: "setup on iOS")
                returnWithTemplate(template)
            case .extraLarge:
                let template = CLKComplicationTemplateExtraLargeSimpleText()
                template.textProvider = CLKSimpleTextProvider(text: "setup on iOS")
                returnWithTemplate(template)
            default: break
            }
            return
        }
        
        
        // Setup
        let showSecondUnit = UserDefaults.standard.bool(forKey: Keys.UD.showSecondUnit)
        var unit = NSCalendar.Unit.init(rawValue: unitRaw)
        //Note: .Era represents Smart Auto
        if unit == .era {
            unit = smartAutoUnit(fromDate: date)
        }
        //Build short text for small complications
        let titleLengthLimit = complication.family == .circularSmall ? 4 : 5
        var titleTextShort = titleText
        if titleTextShort.characters.count > titleLengthLimit {
            let range = titleText.startIndex..<titleTextShort.characters.index(titleTextShort.startIndex, offsetBy: titleLengthLimit)
            titleTextShort = titleTextShort.substring(with: range)
        }
        
        // Build text providers
        let titleTextProvider = CLKSimpleTextProvider(text: titleText, shortText: titleTextShort)
        let numberTextProvider = CLKRelativeDateTextProvider(date: date, style: .natural, units: unit)
        
        // Configure showing multiple units for larger families
        if showSecondUnit {
            numberTextProvider.calendarUnits = displayUnitForBaseUnit(unit, date: date, forFamily: complication.family)
        }
        
        // Build entries and execute handler
        switch complication.family {
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallStackText()
            template.line1TextProvider = numberTextProvider
            template.line2TextProvider = titleTextProvider
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeTallBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: titleText) //numberTextProvider
            template.bodyTextProvider = numberTextProvider // CLKSimpleTextProvider(text: titleText)
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallStackText()
            template.line1TextProvider = numberTextProvider
            template.line2TextProvider = titleTextProvider
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = numberTextProvider
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
        case .utilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider = numberTextProvider
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
        case .extraLarge:
            let template = CLKComplicationTemplateExtraLargeStackText()
            template.line1TextProvider = numberTextProvider
            template.line2TextProvider = titleTextProvider
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
        default: break
        }
    }
    
    // MARK: - Update Scheduling
    
    func getNextRequestedUpdateDate(handler: @escaping (Date?) -> Void) {
        // Call the handler with the date when you would next like to be given the opportunity to update your complication content
        let date = Date(timeIntervalSinceNow: 60*60)
        handler(date);
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        let intervalText = "100 DAYS"
        let shortText = "100D"
        let titleText = "Mom's Birthday"
        let titleTextShort = "BDay"
        switch complication.family {
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallStackText()
            let intervalTextProvider = CLKSimpleTextProvider(text: shortText)
            template.line1TextProvider = intervalTextProvider
            template.line2TextProvider = CLKSimpleTextProvider(text: titleTextShort)
            handler(template)
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: intervalText)
            template.body1TextProvider = CLKSimpleTextProvider(text: titleText)
            handler(template)
        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallStackText()
            let intervalTextProvider = CLKSimpleTextProvider(text: shortText)
            template.line1TextProvider = intervalTextProvider
            template.line2TextProvider = CLKSimpleTextProvider(text: titleTextShort)
            handler(template)
        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            let intervalTextProvider = CLKSimpleTextProvider(text: intervalText)
            template.textProvider = intervalTextProvider
            handler(template)
        case .utilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            let intervalTextProvider = CLKSimpleTextProvider(text: intervalText)
            template.textProvider = intervalTextProvider
            handler(template)
        case .extraLarge:
            let template = CLKComplicationTemplateExtraLargeSimpleText()
            template.textProvider = CLKSimpleTextProvider(text: intervalText)
            handler(template)
        default: break
        }
    }
    
    // MARK: Helper Functions
    func smartAutoUnit(fromDate date: Date) -> NSCalendar.Unit {
        // print("getting smart auto unit")
        let yearInterval = intervalForUnit(.year, fromDate: date)
        guard yearInterval < 1 else {
            return .year
        }
        let monthInterval = intervalForUnit(.month, fromDate: date)
        guard monthInterval < 1 else {
            return .month
        }
        let dayInterval = intervalForUnit(.day, fromDate: date)
        guard dayInterval < 1 else {
            return .day
        }
        let hourInterval = intervalForUnit(.hour, fromDate: date)
        guard hourInterval < 1 else {
            return .hour
        }
        let secondInterval = intervalForUnit(.second, fromDate: date)
        guard secondInterval < 60 else {
            return .minute
        }
        return .second
    }
    func displayUnitForBaseUnit(_ unit: NSCalendar.Unit, date: Date, forFamily family: CLKComplicationFamily) -> NSCalendar.Unit {
        var newUnit: NSCalendar.Unit?
        // Only allow for certain families
        switch family {
        case .modularLarge, .utilitarianLarge, .utilitarianSmall, .extraLarge:
            // Only allow for certain units
            switch unit {
            case NSCalendar.Unit.year: newUnit = .month
            case NSCalendar.Unit.month: newUnit = .day
            case NSCalendar.Unit.day: newUnit = .hour
            case NSCalendar.Unit.hour: newUnit = .minute
            case NSCalendar.Unit.minute: newUnit = .second
            case NSCalendar.Unit.second: break
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
        var units: NSCalendar.Unit = [unit, secondUnit]
        // Test if both units are 0, then use smart unit
        
        let secondUnitInterval = intervalForUnit(secondUnit, fromDate: date)
        if firstUnitInterval == 0 && secondUnitInterval == 0 {
            let smartUnit = smartAutoUnit(fromDate: date)
            units = displayUnitForBaseUnit(smartUnit, date: date, forFamily: family)
        }
        return units
    }
    func intervalForUnit(_ unit: NSCalendar.Unit, fromDate date: Date) -> Int {
        let component = Calendar.Component.init(unit: unit)
        let components = Calendar.current.dateComponents([component], from: date, to: Date())
        let count = components.value(for: component)!
        return abs(count)
    }
}
extension Calendar.Component {
    init(unit: NSCalendar.Unit) {
        switch unit {
        case NSCalendar.Unit.day: self = .day
        case NSCalendar.Unit.month: self = .month
        case NSCalendar.Unit.year: self = .year
        case NSCalendar.Unit.hour: self = .hour
        case NSCalendar.Unit.minute: self = .minute
        case NSCalendar.Unit.second: self = .second
        default:
            assertionFailure("inappropriate unit")
            self = .day
        }
    }
}
