//
//  DateProgressCell.swift
//  GymRats
//
//  Created by mack on 12/7/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

class DateProgressCell: UITableViewCell {

    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startDateLabelLabel: UILabel!
    
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var endDateLabelLabel: UILabel!
    
    @IBOutlet weak var progressBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        progressBackgroundView.backgroundColor = .foreground
        progressBackgroundView.layer.cornerRadius = 4
    }

    func doTheThing(start: Date, end: Date) {
        let totalDays = abs(start.utcDateIsDaysApartFromUtcDate(end))
        let daysLeft = abs(Date().localDateIsDaysApartFromUTCDate(end))
        let percent = max(0.01, min(1, (CGFloat(1) - CGFloat(daysLeft) / CGFloat(totalDays))))
        let width = progressBackgroundView.frame.width * percent
        let progressIndicatorView: UIView = UIView(frame: CGRect(x: 7, y: 7, width: width, height: progressBackgroundView.frame.height-14))
        
        progressIndicatorView.backgroundColor = .brand
        progressIndicatorView.layer.cornerRadius = 4
        
        progressBackgroundView.addSubview(progressIndicatorView)
        
        startDateLabel.text = start.toFormat("MMM d")
        endDateLabel.text = end.toFormat("MMM d")
    }
}
