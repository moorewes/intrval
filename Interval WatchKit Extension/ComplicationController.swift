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
    
    // MARK: - Properties
    
    var dataController = DataController.main
    var templates = ComplicationTemplateBuilder()
    
    // MARK: - CLK Complication Data Source
    
    // MARK: Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: (@escaping (CLKComplicationTimelineEntry?) -> Void)) {
        
        guard let template = counterTemplate(for: complication.family) else {
            handler(nil)
            return
        }
        
        let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
        handler(entry)
    }
    
    func getPlaceholderTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        
        let template = templates.placeholderTemplate(family: complication.family)
        handler(template)
    }
    
    // MARK: Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.backward, .forward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        let oneDayPriorInterval: TimeInterval = -60 * 60 * 24
        let oneDayPriorDate = Date(timeInterval: oneDayPriorInterval, since: Date())
        
        handler(oneDayPriorDate)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        let oneDayForwardInterval: TimeInterval = 60 * 60 * 24
        let oneDayForwardDate = Date(timeInterval: oneDayForwardInterval, since: Date())
        
        handler(oneDayForwardDate)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    @available(watchOSApplicationExtension 7.0, *)
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        handler([CLKComplicationDescriptor(identifier: "Intrval",
                                           displayName: "Intrval",
                                           supportedFamilies: CLKComplicationFamily.allCases)])
    }

    // MARK: - Helper Methods
    
    private func counterTemplate(for family: CLKComplicationFamily) -> CLKComplicationTemplate? {
        if let counter = dataController.complicationCounter,
           let counterTemplate = templates.counterTemplate(counter: counter, family: family) {
            return counterTemplate
        }
        
        let initialTemplate = templates.initialTemplate(family: family)
        
        return initialTemplate
    }
    
}
