//
//  UpcomingChallengeCollectionReusableView.swift
//  GymRats
//
//  Created by Mack on 6/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

class UpcomingChallengeCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var imageView: UserImageView!
    @IBOutlet weak var memberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var challenge: Challenge! {
        didSet {
            imageView.skeletonLoad(avatarInfo: challenge)
            titleLabel.text = challenge.name
            dateLabel.text = "Starts \(challenge.startDate.toFormat("MMMM d"))"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.backgroundColor = .clear
        memberLabel.font = .body
        titleLabel.font = .bigAndBlack
        dateLabel.font = .body
        backgroundColor = .firebrick
    }
    
}
