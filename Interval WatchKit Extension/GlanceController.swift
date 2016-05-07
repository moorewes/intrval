//
//  GlanceController.swift
//  Interval WatchKit Extension
//
//  Created by Wesley Moore on 3/31/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import WatchKit
import Foundation


class GlanceController: WKInterfaceController {
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var intervalDescriptionLabel: WKInterfaceLabel!
    @IBOutlet var timer: WKInterfaceTimer!

    var data: (date: NSDate, title: String)?
    func updateUI(){
        // Test for data
        if let title = NSUserDefaults.standardUserDefaults().stringForKey(Keys.UD.title),
            let date = NSUserDefaults.standardUserDefaults().valueForKey(Keys.UD.referenceDate) as? NSDate {
            //Ensure views are shown
            timer.setHidden(false)
            intervalDescriptionLabel.setHidden(false)
            
            //Setup title and timer
            titleLabel.setText(title)
            timer.setDate(date)
            
            //Setup interval description
            var descriptor: String!
            if date.compare(NSDate()) == .OrderedAscending {
                descriptor = "time since "
            } else {
                descriptor = "time until "
            }
            let dF = NSDateFormatter()
            dF.dateStyle = .ShortStyle
            dF.timeStyle = .ShortStyle
            let dateString = dF.stringFromDate(date)
            intervalDescriptionLabel.setText(descriptor + dateString)
        } else {
            // Load no data defaults and hide views
            titleLabel.setText("Setup on iOS App")
            timer.setHidden(true)
            intervalDescriptionLabel.setHidden(true)
        }
    }
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // print("awakeWithContext")
        updateUI()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        // print("willActivate")
        updateUI()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
