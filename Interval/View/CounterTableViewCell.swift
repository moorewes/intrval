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
    
    internal static let cellID = "counterCell"
    
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
    
    // MARK: - Methods
    
    func refreshIntervalLabel() {
        timeIntervalLabel.text = intervalString()
    }
    
    private func refreshUI() {
        guard let counter = self.counter else { return }
        
        titleLabel.text = counter.title
        
        dateLabel.text = dateFormatter.string(from: counter.date)
        if counter.includeTime {
            dateLabel.text! += "\n \(timeFormatter.string(from: counter.date))"
        }

        refreshIntervalLabel()
    }
    
    private func intervalString() -> String {
        guard let counter = counter else { return "" }
        
        let timeInterval = counter.scaledTimeInterval()
        let interval = timeInterval.value
        var intervalText = "\(abs(interval)) \(timeInterval.unit)"
        
        if interval > 0 {
            intervalText += interval == 1 ? " has passed" : "s have passed"
        } else {
            intervalText += interval == -1 ? " remains" : "s remain"
        }
        
        return intervalText
    }
    
}
