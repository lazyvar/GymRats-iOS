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
    
    @IBOutlet weak var usersLabel: UILabel!
    @IBOutlet weak var calLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    
}
