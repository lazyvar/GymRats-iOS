//
//  UserProfileMenuTableViewCell.swift
//  GymRats
//
//  Created by Mack on 6/1/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

class UserProfileMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UserImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.backgroundColor = .clear
        self.backgroundColor = .firebrick
    }
}
