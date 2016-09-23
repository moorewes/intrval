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

    var data: (date: Date, title: String)?
    func updateUI(){
        // Test for data
        if let title = UserDefaults.standard.string(forKey: Keys.UD.title),
            let date = UserDefaults.standard.value(forKey: Keys.UD.referenceDate) as? Date {
            //Ensure views are shown
            timer.setHidden(false)
            intervalDescriptionLabel.setHidden(false)
            
            //Setup title and timer
            titleLabel.setText(title)
            timer.setDate(date)
            
            //Setup interval description
            var descriptor: String!
            if date.compare(Date()) == .orderedAscending {
                descriptor = "time since "
            } else {
                descriptor = "time until "
            }
            let dF = DateFormatter()
            dF.dateStyle = .short
            dF.timeStyle = .short
            let dateString = dF.string(from: date)
            intervalDescriptionLabel.setText(descriptor + dateString)
        } else {
            // Load no data defaults and hide views
            titleLabel.setText("Setup on iOS App")
            timer.setHidden(true)
            intervalDescriptionLabel.setHidden(true)
        }
    }
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
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
