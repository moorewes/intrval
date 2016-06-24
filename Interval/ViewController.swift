//
//  ViewController.swift
//  Interval
//
//  Created by Wesley Moore on 3/31/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate, UITextFieldDelegate, UITextViewDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var masterView: UIView!
    @IBOutlet weak var intervalLabel: UILabel!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var mainScrollContentView: UIView!
    @IBOutlet weak var confirmDateButton: UIButton!
    @IBOutlet weak var discardDateButton: UIButton!
    @IBOutlet weak var unitButton: UIButton!
    @IBOutlet weak var unitButtonSymbol: UIButton!
    @IBOutlet weak var descriptionLabel: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var dateRow: UIView!
    @IBOutlet weak var intervalTopSpace: NSLayoutConstraint!
    @IBOutlet weak var intervalHeight: NSLayoutConstraint!
    @IBOutlet weak var dateHeight: NSLayoutConstraint!
    @IBOutlet weak var includeTimeTopSpace: NSLayoutConstraint!
    @IBOutlet weak var monthField: UITextField!
    @IBOutlet weak var dayField: UITextField!
    @IBOutlet weak var yearField: UITextField!
    @IBOutlet weak var hourField: UITextField!
    @IBOutlet weak var minuteField: UITextField!
    @IBOutlet weak var meridiemButton: UIButton!
    @IBOutlet weak var dateContainer: UIView!
    @IBOutlet weak var timeContainer: UIView!
    @IBOutlet weak var includeTimeTextButton: UIButton!
    @IBOutlet weak var includeTimeSymbolButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var separatorMonthDay: UILabel!
    @IBOutlet weak var separatorDayYear: UILabel!
    @IBOutlet weak var separatorHourMinute: UILabel!
    
    var loaded = false
    var interval: Interval!
    var session: WCSession?
    var timer: NSTimer!
    var previousScrollOffset: CGPoint?
    var isEditingDate = false
    var intervalTextHeight: CGFloat = 100
    var keyboardHeight: CGFloat = 0
    var includeTime = false
    var hasSaved = false
    let meridiemAM = "AM"
    let meridiemPM = "PM"
    var intervalLabelShrinkageForSmallDevice: CGFloat { return view.bounds.height <= 480 ? -45 : 0 }
    @IBAction func didTapUnit() {
        interval.cycleUnit()
        updateUI()
        //saveData()
    }
    @IBAction func requestShowHideTime() {
        showHideTime(!includeTime)
        UIView.animateWithDuration(0.3,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0,
            options: .CurveEaseIn,
            animations: {
                self.view.layoutIfNeeded()
            },
            completion: { _ in
                self.ensureViewIsVisible(self.dateRow)
                if self.includeTime {
                    self.hourField.becomeFirstResponder()
                }
            }
        )
    }
    func showHideTime(include: Bool) {
        includeTime = include
        var constant: CGFloat!
        switch includeTime {
        case true:
            constant = timeContainer.frame.height
            let color = discardDateButton.titleLabel!.textColor
            includeTimeSymbolButton.setTitleColor(color, forState: .Normal)
            includeTimeTextButton.setTitle("exclude time of day", forState: .Normal)
            includeTimeSymbolButton.setTitle("−", forState: .Normal)
        case false:
            constant = 0
            let color = confirmDateButton.titleLabel!.textColor
            includeTimeSymbolButton.setTitleColor(color, forState: .Normal)
            includeTimeTextButton.setTitle("include time of day", forState: .Normal)
            includeTimeSymbolButton.setTitle("+", forState: .Normal)
        }
        
        timeContainer.hidden = !includeTime
        includeTimeTopSpace.constant = constant
        
    }
    @IBAction func confirmDateChange() {
        guard let date = dateFromUI() else {
            return
        }
        exitEditDate()
        if let text = descriptionLabel.text {
            interval.description = text
        }
        interval.includeTime = includeTime
        interval.date = date
        updateUI()
        saveData()
    }
    @IBAction func toggleMeridiem(sender: UIButton) {
        guard let currentMeridiem = sender.titleLabel?.text else {
            // print("meridiem title label nil")
            return
        }
        var text: String!
        switch currentMeridiem {
        case meridiemAM: text = meridiemPM
        case meridiemPM: text = meridiemAM
        default: text = "ER"
        }
        sender.setTitle(text, forState: .Normal)
        if !isEditingDate {
            saveData()
        }
    }
    @IBAction func cancelEditDate(sender: UIButton) {
        exitEditDate()
        updateUI()
    }
    @IBAction func rateApp() {
        if let url = NSURL(string: "itms-apps://itunes.apple.com/us/app/app-name/id1111883763") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    func exitEditDate() {
        resignDateTextFields()
        if let offset = previousScrollOffset {
            previousScrollOffset = nil
            mainScrollView.setContentOffset(offset, animated: true)
        }
        includeTimeTextButton.hidden = true
        includeTimeSymbolButton.hidden = true
        confirmDateButton.hidden = true
        discardDateButton.hidden = true
    }
    
    func dateFromUI() -> NSDate? {
        var date = ""
        var year = yearField.text!
        var month = monthField.text!
        var day = dayField.text!
        // add leading zeros
        while year.characters.count < 4 {
            year.insert("0", atIndex: year.startIndex)
        }
        while month.characters.count < 2 {
            month.insert("0", atIndex: month.startIndex)
        }
        while day.characters.count < 2 {
            day.insert("0", atIndex: day.startIndex)
        }
        date += month + day + year
        let dateFormatter = NSDateFormatter()
        if includeTime {
            // add leading zeros to time
            var hour = hourField.text!
            var minute = minuteField.text!
            while hour.characters.count < 2 {
                hour.insert("0", atIndex: hour.startIndex)
            }
            while minute.characters.count < 2 {
                minute.insert("0", atIndex: minute.startIndex)
            }
            date += hour + minute + meridiemButton.titleLabel!.text!
            dateFormatter.dateFormat = "MMddyyyyhhmma"
        } else {
            dateFormatter.dateFormat = "MMddyyyy"
        }
        guard let result = dateFormatter.dateFromString(date) else {
            return nil
        }
        return result
    }
    func dateToUI(date: NSDate) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM"
        let month = dateFormatter.stringFromDate(date)
        monthField.text = month
        dateFormatter.dateFormat = "dd"
        let day = dateFormatter.stringFromDate(date)
        dayField.text = day
        dateFormatter.dateFormat = "yyyy"
        let year = dateFormatter.stringFromDate(date)
        yearField.text = year
        if includeTime {
            dateFormatter.dateFormat = "hh"
            let hour = dateFormatter.stringFromDate(date)
            hourField.text = hour
            dateFormatter.dateFormat = "mm"
            let minute = dateFormatter.stringFromDate(date)
            minuteField.text = minute
            dateFormatter.dateFormat = "a"
            let meridiem = dateFormatter.stringFromDate(date)
            meridiemButton.setTitle(meridiem, forState: .Normal)
        }
        showHideTime(includeTime)
    }
    func refreshInterval() {
        intervalLabel.text = interval.measureIntervalToString()
    }
    func updateUI() {
        intervalLabel.text = interval.measureIntervalToString()
        var unitString = interval.unitString + " "
        unitString += interval.measureIntervalToInt() < 1 ? "until" : "since"
        unitButton.setTitle(unitString, forState: .Normal)
        descriptionLabel.text = interval.description
        includeTime = interval.includeTime
        dateToUI(interval.date)
        intervalTextHeight = intervalLabel.requiredHeight()
        setColorScheme()
        if descriptionLabel.text == "" {
            let placeholder = NSAttributedString(string:"tap to set title",
                                                 attributes:[NSForegroundColorAttributeName: Colors.sharedInstance.tColor])
            descriptionLabel.attributedPlaceholder = placeholder
        }
    }
    func setColorScheme() {
        let bColor = Colors.sharedInstance.bColor
        let tColor = Colors.sharedInstance.tColor
        masterView.backgroundColor = bColor
        titleLabel.textColor = tColor
        intervalLabel.textColor = tColor
        unitButton.setTitleColor(tColor, forState: .Normal)
        descriptionLabel.textColor = tColor
        monthField.textColor = tColor
        dayField.textColor = tColor
        yearField.textColor = tColor
        hourField.textColor = tColor
        minuteField.textColor = tColor
        separatorDayYear.textColor = tColor
        separatorMonthDay.textColor = tColor
        separatorHourMinute.textColor = tColor
        meridiemButton.setTitleColor(tColor, forState: .Normal)
        includeTimeTextButton.setTitleColor(tColor, forState: .Normal)
        includeTimeSymbolButton.setTitleColor(tColor, forState: .Normal)
        helpButton.setTitleColor(tColor, forState: .Normal)
        rateButton.setTitleColor(tColor, forState: .Normal)
        statusLabel.textColor = tColor
    }
    func saveData() {
        DataManager.saveUserData(interval)
        if let _ = session {
            sendDataToWatch()
        } else {
            // print("session is nil")
        }
    }
    func sendDataToWatch() {
        if #available(iOS 9.3, *) {
            guard session?.activationState == .Activated else {
                return
            }
        }
        let userInfo = ComplicationDataHelper.createUserInfo(interval.date, title: interval.description)
        WCSession.defaultSession().transferCurrentComplicationUserInfo(userInfo)
        // print("sent message to watch")
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let data = DataManager.retrieveUserData() {
            interval = data
            descriptionLabel.attributedPlaceholder = .None
        } else {
            interval = Interval(date: NSDate(), unit: .Day, includeTime: false, description: descriptionLabel.text!)
            let placeholder = NSAttributedString(string:"tap to set title",
                                                 attributes:[NSForegroundColorAttributeName: Colors.sharedInstance.tColor])
            descriptionLabel.attributedPlaceholder = placeholder
        }
        hasSaved = NSUserDefaults.standardUserDefaults().boolForKey(Keys.UD.hasSaved)
        intervalHeight.constant += intervalLabelShrinkageForSmallDevice
        updateUI()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateKeyboardHeight(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: #selector(refreshInterval), userInfo: nil, repeats: true)
        
        updateStatusLabel()
        
        
        
        
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        loaded = true
        
        let count = NSUserDefaults.standardUserDefaults().integerForKey(Keys.UD.openCount)
        let rateStatus = NSUserDefaults.standardUserDefaults().integerForKey(Keys.UD.rateStatus)
        if count > 7 {
            if rateStatus == 0 {
                presentViewController(rateAlert1, animated: true, completion: nil)
            } else if rateStatus == 2 {
                presentViewController(rateAlert2, animated: true, completion: nil)
            }
            
        }
    }
    func updateStatusLabel() {
        dispatch_async(dispatch_get_main_queue()) {
            if #available(iOS 9.3, *) {
                if let sesh = self.session where sesh.activationState == .Activated {
                    if sesh.watchAppInstalled {
                        self.statusLabel.text = "Status: Connected to watch"
                    } else {
                        self.statusLabel.text = "Status: Intrval watch app not yet installed"
                    }
                    if sesh.paired == false {
                        self.statusLabel.text = "Status: No paired Apple Watch"
                    }
                }
            } else {
                if let sesh = self.session {
                    if sesh.watchAppInstalled == false {
                        self.statusLabel.text = "Status: Not connected to watch"
                    } else {
                        self.statusLabel.text = "Status: Connected to watch"
                    }
                } else {
                    self.statusLabel.text = "Status: Not connected to watch"
                }
            }
        }
    }
    var rateAlert1: UIAlertController {
        let title = "Be Heard"
        let message = "Consider leaving a rating on the app store? You rock 🎸"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let actionYes = UIAlertAction(title: "Yes, I do rock 🤘", style: UIAlertActionStyle.Default) { _ in
            NSUserDefaults.standardUserDefaults().setInteger(1, forKey: Keys.UD.rateStatus)
            self.rateApp()
        }
        let actionLater = UIAlertAction(title: "Later, but I prefer jazz 🎷", style: UIAlertActionStyle.Default) { _ in
            NSUserDefaults.standardUserDefaults().setInteger(2, forKey: Keys.UD.rateStatus)
        }
        let actionNo = UIAlertAction(title: "No, I'm busy 🚽", style: .Default) { _ in
            NSUserDefaults.standardUserDefaults().setInteger(3, forKey: Keys.UD.rateStatus)
        }
        alert.addAction(actionYes)
        alert.addAction(actionLater)
        alert.addAction(actionNo)
        return alert
    }
    var rateAlert2: UIAlertController {
        let title = "Be Heard"
        let message = "Consider jazzing up our page on the app store with your rating and review? 🎷"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let actionYes = UIAlertAction(title: "Yes, my notes are hot 🔥", style: UIAlertActionStyle.Default) { _ in
            NSUserDefaults.standardUserDefaults().setInteger(1, forKey: Keys.UD.rateStatus)
            self.rateApp()
        }
        let actionLater = UIAlertAction(title: "Later, I'm pretending to practice 🎼", style: UIAlertActionStyle.Default) { _ in
            NSUserDefaults.standardUserDefaults().setInteger(2, forKey: Keys.UD.rateStatus)
        }
        let actionNo = UIAlertAction(title: "No, I'm busy 🚽", style: .Default) { _ in
            NSUserDefaults.standardUserDefaults().setInteger(3, forKey: Keys.UD.rateStatus)
        }
        alert.addAction(actionYes)
        alert.addAction(actionLater)
        alert.addAction(actionNo)
        return alert
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if WCSession.isSupported() {
            session = WCSession.defaultSession()
            session?.delegate = self
            session?.activateSession()
            print("session watch state(paired): ", session!.paired)
            print("session watch state(appInstalled): ", session!.watchAppInstalled)
            print("session watch state(complicationEnabled): ", session!.complicationEnabled)
            // print("WCSession activated iOS")
            // print("outstanding transfer count: \(WCSession.defaultSession().outstandingFileTransfers.count)")
        }
    }
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        print("received message")
        if let _ = message["initialLaunch"] as? Bool where hasSaved {
            let reply = ComplicationDataHelper.createUserInfo(interval.date, title: interval.description)
            // print("sent message back")
            replyHandler(reply)
        }
    }
    func sessionDidBecomeInactive(session: WCSession) {
        updateStatusLabel()
        print("sessionDidBecomeInactive")
    }
    func sessionWatchStateDidChange(session: WCSession) {
        updateStatusLabel()
        print("session watch state(paired) changed: ", session.paired)
        print("session watch state(appInstalled) changed: ", session.watchAppInstalled)
        print("session watch state changed(complicationEnabled): ", session.complicationEnabled)
    }
    func sessionDidDeactivate(session: WCSession) {
        print("deactivate session")
        updateStatusLabel()
    }
    // MARK: UITextFieldDelegate
    func updateKeyboardHeight(notification: NSNotification){
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                keyboardHeight = keyboardSize.height
                if isEditingDate {
                    ensureViewIsVisible(dateRow)
                }
            }
        }
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.backgroundColor = UIColor.clearColor()
        if let offset = previousScrollOffset {
            mainScrollView.setContentOffset(offset, animated: true)
        }
        if !confirmDateButton.hidden {
            confirmDateChange()
        }
        return true
    }
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        intervalLabel.hidden = false
        textField.backgroundColor = UIColor.clearColor()
        isEditingDate = false
        mainScrollView.scrollEnabled = true
        return true
    }
    func textFieldDidBeginEditing(textField: UITextField) {
        intervalLabel.hidden = true
        isEditingDate = true
        mainScrollView.scrollEnabled = false
        switch includeTime {
        case true: includeTimeTopSpace.constant = timeContainer.frame.height
        case false: includeTimeTopSpace.constant = 0
        }
        view.layoutIfNeeded()
        //Ensure can see field
        ensureViewIsVisible(dateRow)
//        let minOffsetY = dateRow.frame.maxY + view.bounds.height/3 - view.bounds.height
//        if mainScrollView.contentOffset.y < minOffsetY {
//            previousScrollOffset = mainScrollView.contentOffset
//            let offset = CGPointMake(0, minOffsetY)
//            mainScrollView.setContentOffset(offset, animated: true)
//        }
        //Set background color if needed
        switch textField {
        case hourField, minuteField, yearField, dayField, monthField:
            textField.backgroundColor = Colors.sharedInstance.selectedBColor // UIColor.darkGrayColor()
            textField.textColor = Colors.sharedInstance.selectedTColor //  UIColor.lightGrayColor()
        default: break
        }
        
    }
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // in case just started editing
        if textField.textColor == Colors.sharedInstance.selectedTColor {
            textField.text = ""
            textField.textColor = Colors.sharedInstance.tColor
        }
        // ensure not exceeding max
        var max: Int!
        switch textField {
        case monthField, dayField, hourField, minuteField:
            max = 2
        case yearField:
            max = 4
        default: return true
        }
        //only proceed if max applies
        let char = string.cStringUsingEncoding(NSUTF8StringEncoding)!
        let isBackSpace = strcmp(char, "\\b") == -92
        if textField.text?.characters.count >= max && !isBackSpace {
            //            switch textField {
            //            case monthField: dayField.becomeFirstResponder()
            //            case dayField: yearField.becomeFirstResponder()
            //            case hourField: minuteField.becomeFirstResponder()
            //            default: break
            //            }
            return false
        }
        //move to next field if applicable
        
        return true
    }
    @IBAction func textFieldDidChange(sender: UITextField) {
        // Check if over max character length, return if not setting date
        var withinCharLimit = true
        switch sender {
        case monthField, dayField, hourField, minuteField:
            withinCharLimit = sender.text?.characters.count <= 2
        case yearField:
            withinCharLimit = sender.text?.characters.count <= 4
        default: return
        }
        guard withinCharLimit else {
            sender.deleteBackward()
            return
        }
        // Check if should advance to next field
        var shouldAdvance = false
        // Add leading zeros if needed
        switch sender {
        case dayField:
            for n in 4...9 {
                let string = "\(n)"
                if sender.text == string {
                    shouldAdvance = true
                    sender.text = "0" + string
                }
            }
        case monthField, hourField:
            for n in 2...9 {
                let string = "\(n)"
                if sender.text == string {
                    shouldAdvance = true
                    sender.text = "0" + string
                }
            }
        case minuteField:
            for n in 6...9 {
                let string = "\(n)"
                if sender.text == string {
                    shouldAdvance = true
                    sender.text = "0" + string
                }
            }
        default: break
        }
        let maxChar = sender == yearField ? 4 : 2
        if sender.text!.characters.count == maxChar {
            switch sender {
            case monthField, dayField, hourField, yearField where includeTime: shouldAdvance = true
            default: break
            }
        }
        if shouldAdvance {
            advanceCursorFrom(sender)
        }
        
        if let _ = dateFromUI() {
            confirmDateButton.alpha = 1
            confirmDateButton.enabled = true
        } else {
            confirmDateButton.alpha = 0.2
            confirmDateButton.enabled = false
        }
    }
    @IBAction func beganEditTextField(sender: UITextField) {
        sender.backgroundColor = Colors.sharedInstance.selectedBColor
        confirmDateButton.hidden = false
        includeTimeTextButton.hidden = false
        includeTimeSymbolButton.hidden = false
        discardDateButton.hidden = false
        ensureViewIsVisible(sender)
    }
    @IBAction func endEditTextField(sender: UITextField) {
        sender.backgroundColor = UIColor.clearColor()
        sender.textColor = Colors.sharedInstance.tColor
    }
    @IBAction func changedDescription(sender: UITextField) {
        guard let text = sender.text else { return }
        interval.description = text
        if confirmDateButton.hidden == false {
            //confirmDateChange()
            
            guard let date = dateFromUI() else {
                return
            }
            //exitEditDate()
            if let text = descriptionLabel.text {
                interval.description = text
            }
            interval.includeTime = includeTime
            interval.date = date
            updateUI()
            saveData()
        }
        saveData()
    }

    func resignDateTextFields() {
        monthField.resignFirstResponder()
        dayField.resignFirstResponder()
        yearField.resignFirstResponder()
        minuteField.resignFirstResponder()
        hourField.resignFirstResponder()
        descriptionLabel.resignFirstResponder()
    }
    func advanceCursorFrom(startingField: UITextField){
        var nextField: UITextField!
        switch startingField {
        case monthField: nextField = dayField
        case dayField: nextField = yearField
        case hourField: nextField = minuteField
        case yearField: nextField = hourField
        default: return
        }
        nextField.becomeFirstResponder()
    }
    func ensureViewIsVisible(visibleView: UIView) {
        let minOffsetY = visibleView.frame.maxY + keyboardHeight - view.bounds.height
        if mainScrollView.contentOffset.y < minOffsetY {
            if previousScrollOffset == nil {
                previousScrollOffset = mainScrollView.contentOffset
            }
            let offset = CGPointMake(0, minOffsetY)
            mainScrollView.setContentOffset(offset, animated: true)
        }
    }
}
extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //let range: CGFloat = view.bounds.height/2.5
        let max = view.bounds.height/2 - intervalTextHeight + 10
        let offset = min(max, scrollView.contentOffset.y)
        intervalHeight.constant = -offset + intervalLabelShrinkageForSmallDevice
        intervalTopSpace.constant = 25 + min(max, offset)
        view.layoutIfNeeded()
    }
    
}

