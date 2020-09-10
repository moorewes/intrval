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
    @IBOutlet weak var dateLabelUpperConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateLabelCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var alertImageView: UIImageView!

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
        if interval.includeTime {
            timeLabel.text = df.string(from: interval.date)
        } else {
            timeLabel.text = ""
        }
        //alertImageView.isHidden = !interval.hasAlerts
        setDateLabelPosition()
        refreshIntervalLabel()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.refreshIntervalLabel()
        })
    }
    

    func refreshIntervalLabel() {
        timeIntervalLabel.text = interval.smartIntervalFullString()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setDateLabelPosition() {
        dateLabelUpperConstraint.isActive = interval.includeTime
        dateLabelCenterConstraint.isActive = !interval.includeTime
        layoutIfNeeded()
    }

}
