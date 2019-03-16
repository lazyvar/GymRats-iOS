//
//  CommentTableViewCell.swift
//  GymRats
//
//  Created by Mack on 3/16/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UserImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameLabel.font = .detailsBold
        commentLabel.font = .details
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        userImageView.userImage = nil
        nameLabel.text = nil
        commentLabel.text = nil
    }
}
