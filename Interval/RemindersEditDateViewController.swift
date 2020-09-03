////
////  RemindersEditDateViewController.swift
////  Interval
////
////  Created by Wesley Moore on 8/4/17.
////  Copyright © 2017 Wes Moore. All rights reserved.
////
//
//import UIKit
//
//class RemindersEditDateViewController: UIViewController {
//    
//    var reminder: Reminder!
//    
//    @IBOutlet weak var datePicker: UIDatePicker!
//    
//    @IBAction func choseSave() {
//        reminder.fireDate = datePicker.date
//        print(reminder.fireDate.localeDescription)
//        navigationController?.popViewController(animated: true)
//    }
//    
//    @IBAction func choseCancel() {
//        navigationController?.popViewController(animated: true)
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        datePicker.minimumDate = Date().withZeroSeconds
//        datePicker.date = reminder.fireDate
//        navigationItem.backBarButtonItem?.setTitleTextAttributes(convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): Theme.navigationBarFont]), for: .normal)
//        navigationItem.backBarButtonItem?.tintColor = UIColor.white
//    }
//
//
//}
//
//// Helper function inserted by Swift 4.2 migrator.
//fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
//	guard let input = input else { return nil }
//	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
//}
//
//// Helper function inserted by Swift 4.2 migrator.
//fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
//	return input.rawValue
//}
