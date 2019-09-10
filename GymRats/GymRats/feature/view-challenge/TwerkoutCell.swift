//
//  TwerkoutCell.swift
//  GymRats
//
//  Created by Mack on 9/8/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

class TwerkoutCell: UITableViewCell {
    
    @IBOutlet weak var twerk: UIImageView!
    @IBOutlet weak var little: UILabel!
    @IBOutlet weak var det: UILabel!
    @IBOutlet weak var tit: UILabel!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var lil: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        shadowView.layer.shadowRadius = 5
        shadowView.layer.shadowColor = UIColor.gray.withAlphaComponent(0.7).cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
        shadowView.layer.shadowOpacity = 0.5
        
        twerk.contentMode = .scaleAspectFill
        twerk.layer.cornerRadius = 4
        accessoryType = .disclosureIndicator
        clipsToBounds = false
    }
}
