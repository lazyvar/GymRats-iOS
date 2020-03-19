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
    @IBOutlet weak var joinLabel: UILabel!
    @IBOutlet weak var leaveChallenge: UIButton! {
        didSet {
//            leaveChallenge.backgroundColor = .white
            leaveChallenge.setTitle("Leave Challenge", for: .normal)
            leaveChallenge.setTitleColor(.black, for: .normal)
            leaveChallenge.titleLabel?.font = .body
            leaveChallenge.layer.cornerRadius = 8
            leaveChallenge.clipsToBounds = true
        }
    }
    var challenge: Challenge! {
        didSet {
            imageView.skeletonLoad(avatarInfo: challenge)
            titleLabel.text = challenge.name
            dateLabel.text = "Goes from \(challenge.startDate.toFormat("MMMM d")) to \(challenge.endDate.toFormat("MMMM d"))"
            joinLabel.text = "Join code: \(challenge.code)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.backgroundColor = .clear
        memberLabel.font = .body
        titleLabel.font = .bigAndBlack
        dateLabel.font = .body
        joinLabel.font = .body
        backgroundColor = .brand
    }
    
}
