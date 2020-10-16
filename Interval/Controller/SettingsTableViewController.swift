//
//  SettingsTableViewController.swift
//  Interval
//
//  Created by Wes Moore on 10/12/20.
//  Copyright © 2020 Wes Moore. All rights reserved.
//

import UIKit
import MessageUI

class SettingsTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    private var mailController: MFMailComposeViewController!
    
    // MARK: - IBActions
    
    @IBAction func didTapContactCell() {
        presentMailView()
    }
    
    @IBAction func didTapRateCell() {
        rateApp()
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMailController()
    }
    
    // MARK: - Helper Methods
        
    private func rateApp() {
        if let url = URL(string: "itms-apps://itunes.apple.com/us/app/app-name/id1111883763") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    private func presentMailView() {
        guard MFMailComposeViewController.canSendMail() else {
            presentContactInfoAlert()
            return
        }

        self.present(mailController, animated: true, completion: nil)
    }
    
    private func setupMailController() {
        mailController = MFMailComposeViewController()
        
        mailController.mailComposeDelegate = self
        mailController.setToRecipients(["wesmooredesign@gmail.com"])
        mailController.setSubject("Intrval Feedback")
        
        let version = (Bundle.main.releaseVersionNumber ?? "") + " " + (Bundle.main.buildVersionNumber ?? "")
        let iOSVersion = UIDevice.current.systemVersion
        
        let bodyText = "\n\n\nUseful Info:\nIntrval Version: \(version)\niOS Version: \(iOSVersion)"
        mailController.setMessageBody(bodyText, isHTML: false)
    }
    
    private func presentContactInfoAlert() {
        let alert = UIAlertController(title: "Contact Developer",
                                      message: "Please email Wes at wesmooredesign@gmail.com",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func presentMailFailureAlert() {
        let alert = UIAlertController(title: "Email Failed To Send",
                                      message: "Please try again or send an email to wesmooredesign@gmail.com",
                                      preferredStyle: UIAlertController.Style.alert )
        self.present(alert, animated: true, completion: { () -> Void in
            self.dismiss(animated: true, completion: nil)
        })
    }

}

// MARK: - MFMailComposeViewController Delegate

extension SettingsTableViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case MFMailComposeResult.failed:
            presentMailFailureAlert()
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}
