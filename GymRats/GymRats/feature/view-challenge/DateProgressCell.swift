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

    func doTheThing(challenge: Challenge) {
        DispatchQueue.main.async {
            let start = challenge.startDate
            let end = challenge.endDate
            let totalDays = abs(start.utcDateIsDaysApartFromUtcDate(end))
            let daysLeft = abs(Date().localDateIsDaysApartFromUTCDate(end))
            let percent: CGFloat
            
            if challenge.isPast {
                percent = 1
            } else {
                percent = max(0.01, min(1, (CGFloat(1) - CGFloat(daysLeft) / CGFloat(totalDays))))
            }
            
            let width = (self.progressBackgroundView.frame.width-14) * percent
            let progressIndicatorView: UIView = UIView(frame: CGRect(x: 7, y: 7, width: width, height: self.progressBackgroundView.frame.height-14))
            
            progressIndicatorView.backgroundColor = .brand
            progressIndicatorView.layer.cornerRadius = 4
            
            self.progressBackgroundView.addSubview(progressIndicatorView)
            
            self.startDateLabel.text = start.toFormat("MMM d")
            self.endDateLabel.text = end.toFormat("MMM d")
        }
    }
}
