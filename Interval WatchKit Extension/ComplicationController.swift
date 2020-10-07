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
        
        print("getting current entry")
        
        guard let interval = DataController.main.complicationCounter else {
            
            print("no values in userDefaults")
            
            let template = self.template(for: complication.family)
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
            return
        }
        
        // TODO: fix when not including time, don't show hours?
        
        // Setup
        let showSecondUnit = !UserSettings.showOnlyOneUnit
        var unit = NSCalendar.Unit.era // NSCalendar.Unit.init(rawValue: interval.unit)
        //Note: .Era represents Smart Auto
        if unit == .era {
            unit = smartAutoUnit(fromDate: interval.date)
        }
        //Build short text for small complications
        let titleLengthLimit = complication.family == .circularSmall ? 4 : 5
        var titleTextShort = interval.title
        if titleTextShort.count > titleLengthLimit {
            let range = interval.title.startIndex..<titleTextShort.index(titleTextShort.startIndex, offsetBy: titleLengthLimit)
            let shortText = String(titleTextShort[range])
            titleTextShort = shortText
        }
        
        // Build text providers
        let titleTextProvider = CLKSimpleTextProvider(text: interval.title, shortText: titleTextShort)
        let numberTextProvider = CLKRelativeDateTextProvider(date: interval.date, style: .natural, units: unit)
        
        // Configure showing multiple units for larger families
        if showSecondUnit {
            numberTextProvider.calendarUnits = displayUnitForBaseUnit(unit, date: interval.date, forFamily: complication.family)
        }
        let useTopRowForTitle = UserSettings.useTopRowForTitle
        
        // Build entries and execute handler
        switch complication.family {
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallStackText()
            if useTopRowForTitle {
                template.line1TextProvider = titleTextProvider
                template.line2TextProvider = numberTextProvider
            } else {
                template.line1TextProvider = numberTextProvider
                template.line2TextProvider = titleTextProvider
            }
            
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeTallBody()
            if useTopRowForTitle {
                template.headerTextProvider = CLKSimpleTextProvider(text: interval.title)
                template.bodyTextProvider = numberTextProvider
            } else {
                template.headerTextProvider = numberTextProvider
                template.bodyTextProvider = CLKSimpleTextProvider(text: interval.title)
            }
            
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallStackText()
            if useTopRowForTitle {
                template.line1TextProvider = titleTextProvider
                template.line2TextProvider = numberTextProvider
            } else {
                template.line1TextProvider = numberTextProvider
                template.line2TextProvider = titleTextProvider
            }
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = numberTextProvider
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
        case . utilitarianSmallFlat:
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
            if #available(watchOS 3.0, *) {
                let template = CLKComplicationTemplateExtraLargeStackText()
                if useTopRowForTitle {
                    template.line1TextProvider = titleTextProvider
                    template.line2TextProvider = numberTextProvider
                } else {
                    template.line1TextProvider = numberTextProvider
                    template.line2TextProvider = titleTextProvider
                }
                let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
                handler(entry)
            }

        case .graphicCorner:
            let template = CLKComplicationTemplateGraphicCornerStackText()
            template.innerTextProvider = titleTextProvider
            template.outerTextProvider = numberTextProvider
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
            break

        case .graphicRectangular:
            let text = interval.inPast ? "since" : "until"
            let template = CLKComplicationTemplateGraphicRectangularStandardBody()
            template.headerTextProvider = numberTextProvider
            template.body1TextProvider = CLKSimpleTextProvider(text: text)
            template.body1TextProvider.tintColor = UIColor.init(white: 1, alpha: 0.3)
            template.body2TextProvider = titleTextProvider
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
            break
    //        case .graphicCircular:
    //            let startDate = interval.isBeforeNow ? interval.date : Date()
    //            let endDate = interval.isBeforeNow ? Date() : interval.date
    //            let gaugeProvider = CLKTimeIntervalGaugeProvider(style: .fill, gaugeColors: [UIColor.clear], gaugeColorLocations: nil, start: startDate, startFillFraction: 0, end: endDate, endFillFraction: 1)
    //            let unitProvider = CLKSimpleTextProvider(text: interval.unit)
    //            unitProvider.
    //
    //            let template = CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText()
    //            template.centerTextProvider = numberTextProvider
    //            template.bottomTextProvider = unitTextProvide
    //
    //            template.gaugeProvider = gaugeProvider
    //            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
    //            handler(entry)
    //            break
                
    //        case .graphicBezel:
    //            let circularTemplate = CLKComplicationTemplateGraphicCircularStackText()
    //            circularTemplate.line1TextProvider = CLKSimpleTextProvider(text: "")
    //            let template = CLKComplicationTemplateGraphicBezelCircularText()
    //            template.textProvider = numberTextProvider
    //            template.circularTemplate = circularTemplate
    //
    //            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
    //            handler(entry)
        default:
            break
        }
    }
    
    // MARK: - Update Scheduling
    
//    func getNextRequestedUpdateDate(handler: @escaping (Date?) -> Void) {
//        // Call the handler with the date when you would next like to be given the opportunity to update your complication content
//        let date = Date(timeIntervalSinceNow: 2*60*60)
//        handler(date);
//    }
    
    
    
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
            if #available(watchOS 3.0, *) {
                let template = CLKComplicationTemplateExtraLargeSimpleText()
                template.textProvider = CLKSimpleTextProvider(text: intervalText)
                handler(template)
            }
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
        guard hourInterval < 2 else {
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
        case .modularLarge, .utilitarianLarge, .utilitarianSmall, .extraLarge, .graphicRectangular:
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
    
    private func template(for family: CLKComplicationFamily) -> CLKComplicationTemplate {
        switch family {
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: "setup")
            template.line2TextProvider = CLKSimpleTextProvider(text: "iOS")
            return template
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: "Setup with iOS app")
            template.body1TextProvider = CLKSimpleTextProvider(text: "")
            return template
        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallSimpleText()
            template.textProvider = CLKSimpleTextProvider(text: "setup")
            return template
        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = CLKSimpleTextProvider(text: "setup iOS")
            return template
        case .utilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider = CLKSimpleTextProvider(text: "setup on iOS")
            return template
        case .extraLarge:
            let template = CLKComplicationTemplateExtraLargeSimpleText()
            template.textProvider = CLKSimpleTextProvider(text: "setup on iOS")
            return template
        default: return CLKComplicationTemplate() // TODO: Support all families
        }
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
