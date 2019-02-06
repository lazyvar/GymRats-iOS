//
//  UserWorkoutTableViewCell.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import AvatarImageView
import SwiftDate

class UserWorkoutTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UserImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.isHidden = true
        detailsLabel.isHidden = true
        fullNameLabel.isHidden = true
        contentView.alpha = 1.0
        accessoryView = nil
        addDivider()
    }
    
    var userWorkout: UserWorkout! {
        didSet {
            let user = userWorkout.user

            userImageView.load(user: user)
            
            if let workout = userWorkout.workout {
                titleLabel.isHidden = false
                detailsLabel.isHidden = false
                titleLabel.text = workout.title
                detailsLabel.text = user.fullName
                
                let label = UILabel()
                label.text = workout.date.in(region: .current).toFormat("h:mm a")
                label.font = UIFont.systemFont(ofSize: 12)
                label.sizeToFit()
                
                accessoryView = label
            } else {
                fullNameLabel.isHidden = false
                fullNameLabel.text = userWorkout.user.fullName
                
                let label = UILabel()
                label.text = "Zzz"
                label.font = UIFont.systemFont(ofSize: 12)
                label.sizeToFit()
                label.alpha = 0.333
                label.textColor = .fog
                
                accessoryView = label
                contentView.alpha = 0.333
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.isHidden = true
        detailsLabel.isHidden = true
        fullNameLabel.isHidden = true
        contentView.alpha = 1.0
        accessoryView = nil
    }
    
}
