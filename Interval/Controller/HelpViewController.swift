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
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func tapRate() {
        if let url = URL(string: "itms-apps://itunes.apple.com/us/app/app-name/id1111883763") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    @IBAction func tapSupport() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["wesmooredesign@gmail.com"])
            mail.setSubject("Intrval Feedback")
            let version = (Bundle.main.releaseVersionNumber ?? "") + " " + (Bundle.main.buildVersionNumber ?? "")
            let deviceModel = UIDevice.current.modelName
            let iOSVersion = UIDevice.current.systemVersion
            let bodyText = "\n\n\nUseful Info:\nIntrval Version: \(version)\nDevice Model: \(deviceModel)\niOS Version: \(iOSVersion)"
            mail.setMessageBody(bodyText, isHTML: false)
            self.present(mail, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Contanct Developer",
                                          message: "Please email Wes at wesmooredesign@gmail.com",
                                          preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
//    func updateUI() {
//        let bColor = Colors.sharedInstance.bColor
//        let tColor = Colors.sharedInstance.tColor
//        view.backgroundColor = bColor
//        help1.textColor = tColor
//        help2.textColor = tColor
//        help3.textColor = tColor
//        help4.textColor = tColor
//        help5.textColor = tColor
//        help6.textColor = tColor
//        versionLabel.textColor = tColor
//        versionLabel.text = "Version 1.2.0 (14)"
//        rateButton.setTitleColor(tColor, for: UIControlState())
//        supportButton.setTitleColor(tColor, for: UIControlState())
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
                
        if let version = Bundle.main.releaseVersionNumber, let build = Bundle.main.buildVersionNumber {
            versionLabel.text = "Designed By Wes Moore\nVersion \(version) (\(build))"
        } else {
            versionLabel.text = ""
        }
        
        //updateUI()
    }
    override func viewDidAppear(_ animated: Bool) {
        if view.bounds.height < 500 {
            rateButton.isHidden = true
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case MFMailComposeResult.failed:
            //print("Mail sent failure")
            let alert = UIAlertController(title: "Email Failed To Send", message: "Please try again or use your own email client and send to wesmooredesign@gmail.com", preferredStyle: UIAlertController.Style.alert )
            self.present(alert, animated: true, completion: { () -> Void in
                self.dismiss(animated: true, completion: nil)
            })
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}
