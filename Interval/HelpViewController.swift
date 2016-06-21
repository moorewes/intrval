//
//  HelpViewController.swift
//  Interval
//
//  Created by Wesley Moore on 5/13/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

    @IBAction func tapReturn() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func tapRate() {
        if let url = NSURL(string: "itms-apps://itunes.apple.com/us/app/app-name/id1111883763") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
}
