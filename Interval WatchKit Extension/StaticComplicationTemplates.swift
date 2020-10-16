//
//  DefaultComplicationTemplates.swift
//  Interval WatchKit Extension
//
//  Created by Wes Moore on 10/8/20.
//  Copyright © 2020 Wes Moore. All rights reserved.
//

import ClockKit
import Foundation

protocol TextProviding {
    var line1: CLKSimpleTextProvider { get }
    var line2: CLKSimpleTextProvider { get }
}

struct StaticComplicationTemplates {
    
    enum TemplateType {
        case placeholder, initial
    }

    private var line1Provider = CLKSimpleTextProvider()
    private var line2Provider = CLKSimpleTextProvider()
    
    func template(type: TemplateType,
                  for family: CLKComplicationFamily) -> CLKComplicationTemplate? {
        return staticTemplate(type: type, for: family)
    }

    private func staticTemplate(type: TemplateType,
                                for family: CLKComplicationFamily) -> CLKComplicationTemplate? {
        setupTextProviders(for: type)
        
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
    
    // MARK: - Helper Methods
    
    private func setupTextProviders(for type: TemplateType) {
        switch type {
        case .initial:
            line1Provider.text = "Setup"
            line2Provider.text = ""
        case .placeholder:
            line1Provider.text = "7D 3Hr"
            line2Provider.text = "Trip"
        }
    }
    
    // MARK: Templates
    
    private func modularSmallTemplate() -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateModularSmallStackText()
        template.line1TextProvider = line1Provider
        template.line2TextProvider = line2Provider
        
        return template
    }
    
    private func circularSmallTemplate() -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateCircularSmallStackText()
        template.line1TextProvider = line1Provider
        template.line2TextProvider = line2Provider
        
        return template
    }
    
    private func modularLargeTemplate() -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateModularLargeTallBody()
        template.headerTextProvider = line1Provider
        template.bodyTextProvider = line2Provider
        
        return template
    }
    
    private func utilitarianSmallFlatTemplate() -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateUtilitarianSmallFlat()
        template.textProvider = line1Provider
        
        return template
    }
    
    private func utilitarianLargeTemplate() -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateUtilitarianLargeFlat()
        template.textProvider = line1Provider
        
        return template
    }
    
    private func extraLargeTemplate() -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateExtraLargeStackText()
        template.line1TextProvider = line1Provider
        template.line2TextProvider = line2Provider
        
        return template
    }
    
    private func graphicCornerTemplate() -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateGraphicCornerStackText()
        template.innerTextProvider = line1Provider
        template.outerTextProvider = line2Provider
        
        return template
    }
    
    private func graphicRectangularTemplate() -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateGraphicRectangularStandardBody()
        template.headerTextProvider = line1Provider
        template.body1TextProvider = CLKSimpleTextProvider(text: "until")
        template.body1TextProvider.tintColor = UIColor.init(white: 1, alpha: 0.3)
        template.body2TextProvider = line2Provider
        
        return template
    }
    
    private func graphicCircularTemplate() -> CLKComplicationTemplateGraphicCircular {
        let template = CLKComplicationTemplateGraphicCircularStackText()
        template.line1TextProvider = line1Provider
        template.line2TextProvider = line2Provider
        
        return template
    }
    
    private func graphicBezelTemplate() -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateGraphicBezelCircularText()
        template.circularTemplate = graphicCircularTemplate()
        
        return template
    }
    
}
