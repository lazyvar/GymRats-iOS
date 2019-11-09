//
//  MenuTableViewCell.swift
//  GymRats
//
//  Created by Mack on 6/1/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UserImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.backgroundColor = .clear
        titleLabel.font = .bodyBold
        self.backgroundColor = .brand
        titleLabel.textColor = .white
    }
    
}
