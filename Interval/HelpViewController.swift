//
//  HelpViewController.swift
//  Interval
//
//  Created by Wesley Moore on 5/13/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var returnButton: UIButton!
    @IBOutlet weak var help1: UILabel!
    @IBOutlet weak var help2: UILabel!
    @IBOutlet weak var help3: UILabel!
    @IBOutlet weak var help4: UILabel!
    @IBOutlet weak var help5: UILabel!
    @IBOutlet weak var help6: UILabel!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!

    @IBAction func tapReturn() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func tapRate() {
        if let url = NSURL(string: "itms-apps://itunes.apple.com/us/app/app-name/id1111883763") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    func updateUI() {
        let bColor = Colors.sharedInstance.bColor
        let tColor = Colors.sharedInstance.tColor
        view.backgroundColor = bColor
        titleLabel.textColor = tColor
        help1.textColor = tColor
        help2.textColor = tColor
        help3.textColor = tColor
        help4.textColor = tColor
        help5.textColor = tColor
        help6.textColor = tColor
        versionLabel.textColor = tColor
        rateButton.setTitleColor(tColor, forState: .Normal)
        returnButton.setTitleColor(tColor, forState: .Normal)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    override func viewDidAppear(animated: Bool) {
        if view.bounds.height < 500 {
            rateButton.hidden = true
        }
    }
    
}
