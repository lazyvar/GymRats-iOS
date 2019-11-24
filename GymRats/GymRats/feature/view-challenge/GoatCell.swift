//
//  GoatCell.swift
//  GymRats
//
//  Created by Mack on 9/8/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

class GoatCell: UITableViewCell {

    @IBOutlet weak var picture: UIImageView! {
        didSet {
            picture.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet weak var calStack: UIStackView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usersLabel: UILabel!
    @IBOutlet weak var calLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    
    @IBOutlet weak var pictureHeight: NSLayoutConstraint!
    @IBOutlet weak var bg: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bg.backgroundColor = .foreground
        bg.layer.cornerRadius = 4
        bg.clipsToBounds = true
    }

}
