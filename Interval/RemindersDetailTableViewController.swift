//
//  RemindersDetailTableViewController.swift
//  Interval
//
//  Created by Wesley Moore on 8/4/17.
//  Copyright © 2017 Wes Moore. All rights reserved.
//

import UIKit

class RemindersDetailTableViewController: UITableViewController, UITextViewDelegate {
    
    var defaultMessageText: String { return "Default (ex. 'One more month until \(reminder.interval!.description)')" }
    
    var reminder: Reminder!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBAction func saveEdit() {
        if messageTextView.text == defaultMessageText {
            reminder.message = ""
        } else {
            reminder.message = messageTextView.text
        }
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelEdit() {
        navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        RemindersDataManager.main.requestPermission()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RemindersEditDateViewController {
            vc.reminder = reminder
        }
    }
 
    // MARK: - UITextViewDelegate
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == defaultMessageText {
            textView.text = ""
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text == "" {
            textView.text = defaultMessageText
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    // MARK: - Convenience 
    
    func updateUI() {
        let text = reminder.fireDate.shortString + " " + reminder.fireDate.timeString
        dateLabel.text = text
        if reminder.message == "" {
            messageTextView.text = defaultMessageText
        } else {
            messageTextView.text = reminder.message
        }
        
    }
}
