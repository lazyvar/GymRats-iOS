//
//  RatsCell.swift
//  GymRats
//
//  Created by mack on 12/8/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

class RatsCell: UITableViewCell {

    @IBOutlet weak var userImageView: UserImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(withHuman human: Account, score: String, scoredBy: ChallengeStatsViewController.SortBy) {
        userImageView.load(avatarInfo: human)
        nameLabel.text = "\(human.fullName)"
        descLabel.text = "\(score) \(scoredBy.description)"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        userImageView.operation?.cancel()
    }
    
}
