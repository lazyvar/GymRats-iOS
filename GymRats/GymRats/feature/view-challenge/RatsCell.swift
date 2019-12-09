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
    
    func configure(withHuman human: User, workouts: Int) {
        userImageView.load(avatarInfo: human)
        nameLabel.text = "\(human.fullName)"
        descLabel.text = "\(workouts) workouts"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        userImageView.operation?.cancel()
    }
    
}
