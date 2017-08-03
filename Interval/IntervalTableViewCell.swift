//
//  IntervalTableViewCell.swift
//  Interval
//
//  Created by Wesley Moore on 8/1/17.
//  Copyright © 2017 Wes Moore. All rights reserved.
//

import UIKit

class IntervalTableViewCell: UITableViewCell {
    
    static let id = "intervalCell"
    
    var interval: Interval!
    var timer: Timer?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeIntervalLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func refreshUI() {
        if interval.description == "" {
            titleLabel.text = "Unnamed Event"
        } else {
            titleLabel.text = interval.description
        }
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        dateLabel.text = df.string(from: interval.date)
        df.dateStyle = .none
        df.timeStyle = .short
        timeLabel.text = df.string(from: interval.date)
        refreshIntervalLabel()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(refreshIntervalLabel), userInfo: nil, repeats: true)
    }
    
    func refreshIntervalLabel() {
        timeIntervalLabel.text = interval.smartIntervalString()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
