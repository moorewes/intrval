//
//  CounterTableViewCell.swift
//  Interval
//
//  Created by Wesley Moore on 8/1/17.
//  Copyright © 2017 Wes Moore. All rights reserved.
//

import UIKit

class CounterTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    internal static let id = "counterCell"
    
    internal var counter: Counter? {
        didSet {
            refreshUI()
        }
    }
        
    private lazy var dateFormatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
        
    }()
    
    private lazy var timeFormatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
        
    }()
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeIntervalLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    // MARK: - Convenience
    
    internal func startUpdatingIntervalLabel() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshIntervalLabel), name: .counterCellShouldUpdateTimeIntervalLabel, object: nil)
    }
    
    internal func refreshUI() {
        
        guard let counter = self.counter else { return }
        
        titleLabel.text = counter.title
        
        dateLabel.text = dateFormatter.string(from: counter.date)
        if counter.includeTime {
            dateLabel.text! += "\n \(timeFormatter.string(from: counter.date))"
        }

        refreshIntervalLabel()

    }
    
    @objc internal func refreshIntervalLabel() {
        guard let counter = counter else { return }
        
        let timeInterval = counter.timeInterval()
        var intervalText = "\(timeInterval.value) \(timeInterval.unit)"
        if timeInterval.value == -1 {
            intervalText += " Remains"
        } else if timeInterval.value < 0 {
            intervalText += " Remain"
        } else if timeInterval.value == 1 {
            intervalText += " Has Passed"
        } else {
            intervalText += " Have Passed"
        }
        
        timeIntervalLabel.text = intervalText
    }


}
