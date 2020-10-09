//
//  ComplicationTemplateBuilder.swift
//  Interval WatchKit Extension
//
//  Created by Wes Moore on 10/8/20.
//  Copyright © 2020 Wes Moore. All rights reserved.
//

import Foundation
import ClockKit

enum ComplicationTemplateType {
    case counter, placeholder, help
}

struct ComplicationTemplateBuilder {

    // MARK: - Methods
    
    func counterTemplate(counter: WatchCounter,
                         family: CLKComplicationFamily) -> CLKComplicationTemplate? {
        let builder = CounterComplicationTemplates(counter: counter)
        return builder.template(for: family)
    }
    
    func placeholderTemplate(family: CLKComplicationFamily) -> CLKComplicationTemplate? {
        let builder = StaticComplicationTemplates()
        return builder.template(type: .placeholder, for: family)
    }
    
    func initialTemplate(family: CLKComplicationFamily) -> CLKComplicationTemplate? {
        let builder = StaticComplicationTemplates()
        return builder.template(type: .initial, for: family)
    }
}
