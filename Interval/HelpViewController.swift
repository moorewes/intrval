//
//  HelpViewController.swift
//  Interval
//
//  Created by Wesley Moore on 5/13/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import UIKit
import MessageUI

class HelpViewController: UIViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var returnButton: UIButton!
    @IBOutlet weak var help1: UILabel!
    @IBOutlet weak var help2: UILabel!
    @IBOutlet weak var help3: UILabel!
    @IBOutlet weak var help4: UILabel!
    @IBOutlet weak var help5: UILabel!
    @IBOutlet weak var help6: UILabel!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var supportButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!

    @IBAction func tapReturn() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func tapRate() {
        if let url = NSURL(string: "itms-apps://itunes.apple.com/us/app/app-name/id1111883763") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    @IBAction func tapSupport() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["wesmooredesign@gmail.com"])
            mail.setSubject("Intrval Feedback")
            let version = (NSBundle.mainBundle().releaseVersionNumber ?? "") + " " + (NSBundle.mainBundle().buildVersionNumber ?? "")
            let deviceModel = UIDevice.currentDevice().modelName
            let iOSVersion = UIDevice.currentDevice().systemVersion
            let bodyText = "\n\n\nUseful Info:\nIntrval Version: \(version)\nDevice Model: \(deviceModel)\niOS Version: \(iOSVersion)"
            mail.setMessageBody(bodyText, isHTML: false)
            self.presentViewController(mail, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Contanct Developer", message: "Please email Wes at wesmooredesign@gmail.com", preferredStyle: .Alert)
            let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
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
        supportButton.setTitleColor(tColor, forState: .Normal)
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
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch result {
        case MFMailComposeResultFailed:
            //print("Mail sent failure")
            let alert = UIAlertController(title: "Email Failed To Send", message: "Please try again or use your own email client and send to wesmooredesign@gmail.com", preferredStyle: UIAlertControllerStyle.Alert )
            self.presentViewController(alert, animated: true, completion: { () -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        default:
            break
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
