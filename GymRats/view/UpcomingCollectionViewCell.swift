//
//  UpcomingCollectionViewCell.swift
//  GymRats
//
//  Created by Mack on 6/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

class UpcomingCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var userImageView: UserImageView!
    @IBOutlet weak var someText: UILabel!
    
    var user: Account! {
        didSet {
            self.someText.text = user.fullName
            self.userImageView.load(user)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        clipsToBounds = false
        someText.font = .bigAndBlack
    }
}
