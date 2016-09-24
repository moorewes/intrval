//
//  ViewController.swift
//  Interval
//
//  Created by Wesley Moore on 3/31/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import UIKit
import WatchConnectivity
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class ViewController: UIViewController, WCSessionDelegate, UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate {
    
    // MARK: Properties
    
    var loaded = false
    var shouldShowStartupHelp = true
    var hasTriedToShowRateRequestThisSession = false
    var interval: Interval!
    var session: WCSession?
    var timer: Timer!
    var previousScrollOffset: CGPoint?
    var isEditingDate = false
    var intervalTextHeight: CGFloat = 100
    var keyboardHeight: CGFloat = 0
    var includeTime = false
    var hasSaved = false
    let meridiemAM = "AM"
    let meridiemPM = "PM"
    var intervalLabelShrinkageForSmallDevice: CGFloat { return view.bounds.height <= 480 ? -45 : 0 }
    
    // MARK: IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separatorLineView: UIView!
    @IBOutlet var masterView: UIView!
    @IBOutlet weak var intervalLabel: UITextField!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var mainScrollContentView: UIView!
    @IBOutlet weak var confirmDateButton: UIButton!
    @IBOutlet weak var discardDateButton: UIButton!
    @IBOutlet weak var setNowButton: UIButton!
    @IBOutlet weak var unitButton: UIButton!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var untilSinceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var startupHelpLabel: UILabel!
    
    @IBOutlet weak var commentView: UIView!
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
    @IBOutlet weak var setIntervalHelp: UILabel!
    @IBOutlet weak var easterEggLabel: UILabel!
    
    @IBOutlet weak var startupLabelTopSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentViewTopSpace: NSLayoutConstraint!
    
    // MARK: IBActions
    
    @IBAction func beginEditInterval() {
        var unit = "days"
        switch interval.unit {
        case NSCalendar.Unit.weekOfYear: unit = "weeks"
        case NSCalendar.Unit.month: unit = "months"
        case NSCalendar.Unit.year: unit = "years"
        case NSCalendar.Unit.hour: unit = "hours"
        case NSCalendar.Unit.minute: unit = "minutes"
        default: break
        }
        setIntervalHelp.text = "Set the date by entering the number of " + unit + " from now (use negatives for the past). Leave blank to cancel."
        setIntervalHelp.isHidden = false
        unitButton.isEnabled = false
        descriptionLabel.isEnabled = false
        helpButton.isHidden = true
        rateButton.isHidden = true
    }
    @IBAction func editedIntervalLabel(_ sender: UITextField) {
        setIntervalHelp.isHidden = true
        unitButton.isEnabled = true
        descriptionLabel.isEnabled = true
        helpButton.isHidden = false
        rateButton.isHidden = false
        guard let intValue = Int(sender.text!) , intValue != abs(interval.measureIntervalToInt()) else {
            updateUI()
            return
        }
        editDateFromInterval(intValue)
    }
    @IBAction func setNow() {
        if !includeTime {
            requestShowHideTime()
        }
        dateToUI(Date())
        
    }
    
    
    
    @IBAction func didTapUnit() {
        interval.cycleUnit()
        updateUI()
    }
    @IBAction func requestShowHideTime() {
        showHideTime(!includeTime)
        UIView.animate(withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0,
            options: .curveEaseIn,
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
        if !hasTriedToShowRateRequestThisSession {
            showRateRequestIfNecessary()
            hasTriedToShowRateRequestThisSession = true
        }
    }
    @IBAction func toggleMeridiem(_ sender: UIButton) {
        guard let currentMeridiem = sender.titleLabel?.text else {
            return
        }
        var text: String!
        switch currentMeridiem {
        case meridiemAM: text = meridiemPM
        case meridiemPM: text = meridiemAM
        default: text = meridiemPM
        }
        sender.setTitle(text, for: UIControlState())
        if !isEditingDate {
            if let date = dateFromUI(text) {
                interval.date = date
            }
            saveData()
        }
    }
    @IBAction func cancelEditDate(_ sender: UIButton) {
        exitEditDate()
        updateUI()
    }
    @IBAction func rateApp() {
        if let url = URL(string: "itms-apps://itunes.apple.com/us/app/app-name/id1111883763") {
            UIApplication.shared.openURL(url)
        }
    }
    
    
    // MARK: Life Cycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if WCSession.isSupported() {
            session = WCSession.default()
            session?.delegate = self
            session?.activate()
            //print("session watch state(paired): ", session!.paired)
            //print("session watch state(appInstalled): ", session!.watchAppInstalled)
            //print("session watch state(complicationEnabled): ", session!.complicationEnabled)
            // print("WCSession activated iOS")
            // print("outstanding transfer count: \(WCSession.defaultSession().outstandingFileTransfers.count)")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.integer(forKey: Keys.UD.openCount) > 5 {
            shouldShowStartupHelp = false
        }
        if let data = DataManager.retrieveUserData() {
            interval = data
            descriptionLabel.attributedPlaceholder = .none
            setTimer()
        } else {
            interval = Interval(date: Date(), unit: .day, includeTime: false, description: descriptionLabel.text!)
            let placeholder = NSAttributedString(string:"tap to set title",
                                                 attributes:[NSForegroundColorAttributeName: Colors.sharedInstance.tColor.withAlphaComponent(0.7)])
            descriptionLabel.attributedPlaceholder = placeholder
            shouldShowStartupHelp = false
        }
        let color = includeTime ? discardDateButton.titleLabel?.textColor : confirmDateButton.titleLabel?.textColor
        includeTimeSymbolButton.setTitleColor(color, for: UIControlState())
        hasSaved = UserDefaults.standard.bool(forKey: Keys.UD.hasSaved)
        intervalHeight.constant += intervalLabelShrinkageForSmallDevice
        updateUI()
        NotificationCenter.default.addObserver(self, selector: #selector(updateKeyboardHeight(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        updateStatusLabel()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loaded = true
        
        intervalLabel.layer.borderColor = Colors.green.cgColor
        intervalLabel.layer.borderWidth = 1
        intervalLabel.layer.cornerRadius = intervalLabel.bounds.width/2
        
        let bottom = dateRow.frame.minY + monthField.frame.minY
        let top = intervalLabel.frame.maxY
        let midDistance = (bottom - top)/2
        let offset = descriptionLabel.frame.midY - commentView.bounds.midY
        commentViewTopSpace.constant = midDistance - offset
        
        if shouldShowStartupHelp {
            let dateY = monthField.frame.minY + dateRow.frame.minY
            let descriptionY = descriptionLabel.frame.maxY + commentView.frame.minY
            let constant = dateY - (dateY - descriptionY)/2
            startupLabelTopSpaceConstraint.constant = constant
            view.layoutIfNeeded()
            startupHelpLabel.alpha = 1
            UIView.animate(withDuration: 1, delay: 4, options: [], animations: {
                self.startupHelpLabel.alpha = 0
                }, completion: nil
            )
        }
    }
    
    // MARK: Convenience
    
    func updateUI() {
        refreshInterval()
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
    func saveData() {
        DataManager.saveUserData(interval)
        if let _ = session {
            sendDataToWatch()
        }
        if timer == nil {
            setTimer()
        }
    }
    func sendDataToWatch() {
        if #available(iOS 9.3, *) {
            guard session?.activationState == .activated else {
                return
            }
        }
        let userInfo = ComplicationDataHelper.createUserInfo(interval.date, title: interval.description)
        WCSession.default().transferCurrentComplicationUserInfo(userInfo)
        //print("sent message to watch")
    }
    
    func exitEditDate() {
        resignDateTextFields()
        if let offset = previousScrollOffset {
            previousScrollOffset = nil
            mainScrollView.setContentOffset(offset, animated: true)
        }
        includeTimeTextButton.isHidden = true
        includeTimeSymbolButton.isHidden = true
        confirmDateButton.isHidden = true
        discardDateButton.isHidden = true
        setNowButton.isHidden = true
    }
    func showHideTime(_ include: Bool) {
        includeTime = include
        var constant: CGFloat!
        switch includeTime {
        case true:
            constant = timeContainer.frame.height
            let color = discardDateButton.titleLabel!.textColor
            includeTimeSymbolButton.setTitleColor(color, for: UIControlState())
            includeTimeTextButton.setTitle("exclude time of day", for: UIControlState())
            includeTimeSymbolButton.setTitle("−", for: UIControlState())
        case false:
            constant = 0
            let color = confirmDateButton.titleLabel!.textColor
            includeTimeSymbolButton.setTitleColor(color, for: UIControlState())
            includeTimeTextButton.setTitle("include time of day", for: UIControlState())
            includeTimeSymbolButton.setTitle("+", for: UIControlState())
        }
        
        timeContainer.isHidden = !includeTime
        includeTimeTopSpace.constant = constant
        
    }
    func dateFromUI(_ withMeridiem: String? = nil) -> Date? {
        var date = ""
        var year = yearField.text!
        var month = monthField.text!
        var day = dayField.text!
        // add leading zeros
        while year.characters.count < 4 {
            year.insert("0", at: year.startIndex)
        }
        while month.characters.count < 2 {
            month.insert("0", at: month.startIndex)
        }
        while day.characters.count < 2 {
            day.insert("0", at: day.startIndex)
        }
        date += month + day + year
        let dateFormatter = DateFormatter()
        if includeTime {
            // add leading zeros to time
            var hour = hourField.text!
            var minute = minuteField.text!
            while hour.characters.count < 2 {
                hour.insert("0", at: hour.startIndex)
            }
            while minute.characters.count < 2 {
                minute.insert("0", at: minute.startIndex)
            }
            let meridiem: String = withMeridiem ?? meridiemButton.titleLabel!.text!
            date += hour + minute + meridiem // meridiemButton.titleLabel!.text!
            dateFormatter.dateFormat = "MMddyyyyhhmma"
        } else {
            dateFormatter.dateFormat = "MMddyyyy"
        }
        guard let result = dateFormatter.date(from: date) else {
            return nil
        }
        return result
    }
    func dateToUI(_ date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        let month = dateFormatter.string(from: date)
        monthField.text = month
        dateFormatter.dateFormat = "dd"
        let day = dateFormatter.string(from: date)
        dayField.text = day
        dateFormatter.dateFormat = "yyyy"
        let year = dateFormatter.string(from: date)
        yearField.text = year
        if includeTime {
            dateFormatter.dateFormat = "hh"
            let hour = dateFormatter.string(from: date)
            hourField.text = hour
            dateFormatter.dateFormat = "mm"
            let minute = dateFormatter.string(from: date)
            minuteField.text = minute
            dateFormatter.dateFormat = "a"
            let meridiem = dateFormatter.string(from: date)
            meridiemButton.setTitle(meridiem, for: UIControlState())
        }
        showHideTime(includeTime)
    }
    func refreshInterval() {
        intervalLabel.text = interval.measureIntervalToString()
        let since = interval.date.compare(Date()) == .orderedAscending
        
        unitLabel.text = interval.unitString.lowercased()
        untilSinceLabel.text = since ? "since" : "until"
    }
    
    func setColorScheme() {
        let bColor = Colors.sharedInstance.bColor
        let tColor = Colors.sharedInstance.tColor
        let intervalDescriptorColor = Colors.sharedInstance.grey
        masterView.backgroundColor = bColor // UIColor(white: 0.97, alpha: 1)
        titleLabel.textColor = tColor
        separatorLineView.backgroundColor = intervalDescriptorColor
        intervalLabel.textColor = tColor
        unitLabel.textColor = intervalDescriptorColor
        untilSinceLabel.textColor = intervalDescriptorColor
        easterEggLabel.textColor = intervalDescriptorColor
        descriptionLabel.textColor = tColor
        monthField.textColor = tColor
        dayField.textColor = tColor
        yearField.textColor = tColor
        hourField.textColor = tColor
        minuteField.textColor = tColor
        separatorDayYear.textColor = tColor
        separatorMonthDay.textColor = tColor
        separatorHourMinute.textColor = tColor
        meridiemButton.setTitleColor(tColor, for: UIControlState())
        includeTimeTextButton.setTitleColor(tColor, for: UIControlState())
        setNowButton.setTitleColor(tColor, for: UIControlState())
        helpButton.setTitleColor(tColor, for: UIControlState())
        rateButton.setTitleColor(tColor, for: UIControlState())
        statusLabel.textColor = tColor
        setIntervalHelp.textColor = tColor
        startupHelpLabel.textColor = tColor
    }
    
    func setTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(refreshInterval), userInfo: nil, repeats: true)
    }
    func editDateFromInterval(_ intValue: Int) {
        guard let newDate = (Calendar.current as NSCalendar).date(byAdding: interval.unit, value: intValue, to: Date(), options: []) else {
            updateUI()
            return
        }
        
        interval.date = newDate
        updateUI()
        saveData()
    }
    
    func showRateRequestIfNecessary() {
        let count = UserDefaults.standard.integer(forKey: Keys.UD.openCount)
        if count > 5 {
            let rateStatusRaw = UserDefaults.standard.integer(forKey: Keys.UD.rateStatus)
            let rateStatus = RateAlertStatus(rawValue: rateStatusRaw)
            
            switch rateStatus {
            case .unseen:
                present(rateAlert1, animated: true, completion: nil)
            case .deferredForNextTime:
                let newValue = RateAlertStatus.deferredForNow.rawValue
                UserDefaults.standard.set(newValue, forKey: Keys.UD.rateStatus)
            case .deferredForNow:
                present(rateAlert2, animated: true, completion: nil)
            default:
                break
            }
        }
    }
    func updateStatusLabel() {
        DispatchQueue.main.async {
            if #available(iOS 9.3, *) {
                if let sesh = self.session , sesh.activationState == .activated {
                    if sesh.isWatchAppInstalled {
                        self.statusLabel.text = ""
                    } else {
                        self.statusLabel.text = "Intrval watch app not yet installed"
                    }
                    if sesh.isPaired == false {
                        self.statusLabel.text = "No paired Apple Watch found"
                    }
                }
            } else {
                if let sesh = self.session {
                    if sesh.isWatchAppInstalled == false {
                        self.statusLabel.text = "Not connected to watch"
                    } else {
                        self.statusLabel.text = ""
                    }
                } else {
                    self.statusLabel.text = "Not connected to watch"
                }
            }
        }
    }
    var rateAlert1: UIAlertController {
        let title = "Be Heard"
        let message = "Please leave a review on the app store. You rock!"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionYes = UIAlertAction(title: "Yes, I do rock 🤘", style: UIAlertActionStyle.default) { _ in
            UserDefaults.standard.set(1, forKey: Keys.UD.rateStatus)
            self.rateApp()
        }
        let actionLater = UIAlertAction(title: "Later", style: UIAlertActionStyle.default) { _ in
            UserDefaults.standard.set(2, forKey: Keys.UD.rateStatus)
        }
        let actionNo = UIAlertAction(title: "No", style: .default) { _ in
            UserDefaults.standard.set(3, forKey: Keys.UD.rateStatus)
        }
        alert.addAction(actionYes)
        alert.addAction(actionLater)
        alert.addAction(actionNo)
        return alert
    }
    var rateAlert2: UIAlertController {
        let title = "Be Heard"
        let message = "Consider leaving us a review?"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionYes = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) { _ in
            UserDefaults.standard.set(1, forKey: Keys.UD.rateStatus)
            self.rateApp()
        }
        let actionLater = UIAlertAction(title: "Later", style: UIAlertActionStyle.default) { _ in
            UserDefaults.standard.set(2, forKey: Keys.UD.rateStatus)
        }
        let actionNo = UIAlertAction(title: "No", style: .default) { _ in
            UserDefaults.standard.set(3, forKey: Keys.UD.rateStatus)
        }
        alert.addAction(actionYes)
        alert.addAction(actionLater)
        alert.addAction(actionNo)
        return alert
    }
    
    
    
    // MARK: UITextFieldDelegate
    
    func updateKeyboardHeight(_ notification: Notification){
        if let userInfo = (notification as NSNotification).userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                keyboardHeight = keyboardSize.height
                if isEditingDate {
                    ensureViewIsVisible(dateRow)
                }
            }
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.backgroundColor = UIColor.clear
        if let offset = previousScrollOffset {
            mainScrollView.setContentOffset(offset, animated: true)
        }
        if !confirmDateButton.isHidden {
            confirmDateChange()
        }
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == intervalLabel { return true }
        intervalLabel.isHidden = false
        unitButton.isHidden = false
        helpButton.isHidden = false
        rateButton.isHidden = false
        titleLabel.isHidden = false
        textField.backgroundColor = UIColor.clear
        isEditingDate = false
        mainScrollView.isScrollEnabled = true
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == intervalLabel { return }
        intervalLabel.isHidden = true
        unitButton.isHidden = true
        helpButton.isHidden = true
        rateButton.isHidden = true
        if view.bounds.height < 500 {
            titleLabel.isHidden = true
        }
        isEditingDate = true
        mainScrollView.isScrollEnabled = false
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
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == intervalLabel { return true }
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
        let char = string.cString(using: String.Encoding.utf8)!
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
    @IBAction private func textFieldDidChange(_ sender: UITextField) {
        if sender == intervalLabel { return }
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
            case monthField, dayField, hourField, 
                 yearField where includeTime: shouldAdvance = true
            default: break
            }
        }
        if shouldAdvance {
            advanceCursorFrom(sender)
        }
        
        if let _ = dateFromUI() {
            confirmDateButton.alpha = 1
            confirmDateButton.isEnabled = true
        } else {
            confirmDateButton.alpha = 0.2
            confirmDateButton.isEnabled = false
        }
    }
    @IBAction func beganEditTextField(_ sender: UITextField) {
        sender.backgroundColor = Colors.sharedInstance.selectedBColor
        confirmDateButton.isHidden = false
        includeTimeTextButton.isHidden = false
        includeTimeSymbolButton.isHidden = false
        discardDateButton.isHidden = false
        setNowButton.isHidden = false
        ensureViewIsVisible(sender)
    }
    @IBAction func endEditTextField(_ sender: UITextField) {
        sender.backgroundColor = UIColor.clear
        sender.textColor = Colors.sharedInstance.tColor
    }
    @IBAction func changedDescription(_ sender: UITextField) {
        guard let text = sender.text else {
            return
        }
        interval.description = text
        if !confirmDateButton.isHidden {
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
            //updateUI()
            //saveData()
        }
        updateUI()
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
    func advanceCursorFrom(_ startingField: UITextField){
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
    func ensureViewIsVisible(_ visibleView: UIView) {
        let minOffsetY = visibleView.frame.maxY + keyboardHeight - view.bounds.height
        if mainScrollView.contentOffset.y < minOffsetY {
            if previousScrollOffset == nil {
                previousScrollOffset = mainScrollView.contentOffset
            }
            let offset = CGPoint(x: 0, y: minOffsetY)
            mainScrollView.setContentOffset(offset, animated: true)
        }
    }
    
    // MARK: WCSession Delegate
    
    @available(iOS 9.3, *)
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
//        if let e = error {
//            print(e.localizedDescription)
//        }
        updateStatusLabel()
    }
    func sessionReachabilityDidChange(_ session: WCSession) {
        updateStatusLabel()
    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        //print("received message")
        if let _ = message["initialLaunch"] as? Bool , hasSaved {
            let reply = ComplicationDataHelper.createUserInfo(interval.date, title: interval.description)
            //print("sent message back")
            replyHandler(reply)
        }
    }
    func sessionDidBecomeInactive(_ session: WCSession) {
        updateStatusLabel()
        //print("sessionDidBecomeInactive")
    }
    func sessionWatchStateDidChange(_ session: WCSession) {
        updateStatusLabel()
        //print("session watch state(paired) changed: ", session.paired)
        //print("session watch state(appInstalled) changed: ", session.watchAppInstalled)
        //print("session watch state changed(complicationEnabled): ", session.complicationEnabled)
    }
    func sessionDidDeactivate(_ session: WCSession) {
        //print("deactivate session")
        updateStatusLabel()
    }
    
    // MARK: UIScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //let range: CGFloat = view.bounds.height/2.5
        let max = view.bounds.height/2 - intervalTextHeight + 10
        let baseHeight = intervalHeight.multiplier * view.bounds.height
        let offset = min(baseHeight, scrollView.contentOffset.y)
        let constant = intervalLabelShrinkageForSmallDevice - offset
        intervalHeight.constant = constant
        intervalTopSpace.constant = 115 + min(max, offset)
        
        let newHeight = intervalHeight.multiplier * view.bounds.height + constant
        intervalLabel.layer.cornerRadius = newHeight/2
        
        
        let intervalDescriptorsDisappearOffset: CGFloat = 50
        let alpha = 1 - min(1, scrollView.contentOffset.y/intervalDescriptorsDisappearOffset)
        unitLabel.alpha = alpha
        untilSinceLabel.alpha = alpha
        
        if scrollView.contentOffset.y < -350 {
            easterEggLabel.alpha = 1
        } else {
            easterEggLabel.alpha = 0
        }
        
        view.layoutIfNeeded()
    }
    
}



