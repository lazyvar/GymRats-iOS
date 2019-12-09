//
//  HumanCell.swift
//  GymRats
//
//  Created by Mack on 9/8/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

class HumanCell: UICollectionViewCell {

    @IBOutlet weak var userImageView: UserImageView!
    @IBOutlet weak var humanLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        userImageView.userImage = nil
    }

}
