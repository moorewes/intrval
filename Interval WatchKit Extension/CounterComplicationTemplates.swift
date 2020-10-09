//
//  CounterComplicationTemplates.swift
//  Interval WatchKit Extension
//
//  Created by Wes Moore on 10/8/20.
//  Copyright © 2020 Wes Moore. All rights reserved.
//

import Foundation
import ClockKit

class CounterComplicationTemplates {
    
    // MARK: - Properties
    
    var line1TextProvider = CLKTextProvider()
    var line2TextProvider = CLKTextProvider()
    
    var numberTextProvider = CLKRelativeDateTextProvider()
    var titleTextProvider = CLKSimpleTextProvider()
        
    // MARK: - Initializers
    
    init(counter: WatchCounter) {
        setupTextProviders(counter: counter)
    }
    
    // MARK: - Methods
    
    // MARK: Internal
    
    func template(for family: CLKComplicationFamily) -> CLKComplicationTemplate? {
            
        switch family {
        
        case .modularSmall:
            return modularSmallTemplate()
            
        case .modularLarge:
            return modularLargeTemplate()
            
        case .circularSmall:
            return circularSmallTemplate()
            
        case .utilitarianSmall, .utilitarianSmallFlat:
            return utilitarianSmallFlatTemplate()
            
        case .utilitarianLarge:
            return utilitarianLargeTemplate()
            
        case .extraLarge:
            return extraLargeTemplate()

        case .graphicCorner:
            return graphicCornerTemplate()

        case .graphicRectangular:
            return graphicRectangularTemplate()
            
        case .graphicCircular:
            return graphicCircularTemplate()
            
        case .graphicBezel:
            return graphicBezelTemplate()

        default:
            return nil
            
        }

    }
    
    // MARK: Helper: Templates
    
    private func modularSmallTemplate() -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateModularSmallStackText()
        template.line1TextProvider = line1TextProvider
        template.line2TextProvider = line2TextProvider
        
        return template
    }
    
    private func circularSmallTemplate() -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateCircularSmallStackText()
        template.line1TextProvider = line1TextProvider
        template.line2TextProvider = line2TextProvider
        
        return template
    }
    
    private func modularLargeTemplate() -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateModularLargeTallBody()
        template.headerTextProvider = line1TextProvider
        template.bodyTextProvider = line2TextProvider
        
        return template
    }
    
    private func utilitarianSmallFlatTemplate() -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateUtilitarianSmallFlat()
        template.textProvider = numberTextProvider
        
        return template
    }
    
    private func utilitarianLargeTemplate() -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateUtilitarianLargeFlat()
        template.textProvider = numberTextProvider
        
        return template
    }
    
    private func extraLargeTemplate() -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateExtraLargeStackText()
        template.line1TextProvider = line1TextProvider
        template.line2TextProvider = line2TextProvider
        
        return template
    }
    
    private func graphicCornerTemplate() -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateGraphicCornerStackText()
        template.innerTextProvider = numberTextProvider
        template.outerTextProvider = titleTextProvider
        
        return template
    }
    
    private func graphicRectangularTemplate() -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateGraphicRectangularStandardBody()
        template.headerTextProvider = numberTextProvider
        
        let dateIsInFuture = Date() < numberTextProvider.date
        let text = dateIsInFuture ? "until" : "since"
        template.body1TextProvider = CLKSimpleTextProvider(text: text)
        
        template.body1TextProvider.tintColor = UIColor.init(white: 1, alpha: 0.3)
        template.body2TextProvider = titleTextProvider
        
        return template
    }
    
    private func graphicCircularTemplate() -> CLKComplicationTemplateGraphicCircular {
        let template = CLKComplicationTemplateGraphicCircularStackText()
        template.line1TextProvider = line1TextProvider
        template.line2TextProvider = line2TextProvider
        
        return template
    }
    
    private func graphicBezelTemplate() -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateGraphicBezelCircularText()
        template.circularTemplate = graphicCircularTemplate()
        
        return template
    }
    
    // MARK: Helper: Utility
    
    private func setupTextProviders(counter: WatchCounter) {
        let shortTitle = shortString(for: counter.title, limit: 5)
        titleTextProvider = CLKSimpleTextProvider(text: counter.title, shortText: shortTitle)
        
        let interval = Interval(date: counter.date, includeTime: counter.includeTime)
        let units = displayUnits(for: interval)
        numberTextProvider = CLKRelativeDateTextProvider(date: counter.date, style: .naturalFull, units: units)
        
        let useTopTitle = UserSettings.useTopRowForTitle
        line1TextProvider = useTopTitle ? titleTextProvider : numberTextProvider
        line2TextProvider = useTopTitle ? numberTextProvider : titleTextProvider
    }
    
    private func displayUnits(for interval: Interval) -> NSCalendar.Unit {
        let greaterUnit = NSCalendar.Unit(component: interval.unit)
        
        guard !UserSettings.showOnlyOneUnit,
              let lessorUnit = greaterUnit.nextSmallerUnit(),
              // Showing hours with days is unnecessary
              greaterUnit != .day,
              // Only show weeks with months if less than 3 months
              !(greaterUnit == .month && interval.value > 2) else {
            
            return greaterUnit
        }
        
        return [greaterUnit, lessorUnit]
    }
    
    private func shortString(for string: String, limit: Int) -> String {
        var original = string
        var result = ""
        while result.count < limit && !original.isEmpty {
            let char = original.removeFirst()
            
            // Avoid ending with a vowel
            if result.count < limit - 1 {
                result.append(char)
            } else if !isVowel(char) {
                result.append(char)
            }
            
        }
        
        return result
    }
    
    private func isVowel(_ char: String.Element) -> Bool {
        switch char {
        case "a", "e", "i", "o", "u":
            return true
        default:
            return false
        }
    }
    
}
