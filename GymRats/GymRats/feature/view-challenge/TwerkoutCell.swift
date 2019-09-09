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

    override func awakeFromNib() {
        super.awakeFromNib()
        
        twerk.layer.shadowRadius = 7
        twerk.layer.shadowColor = UIColor.black.cgColor
        twerk.layer.shadowOffset = CGSize(width: 0, height: 0)
        twerk.contentMode = .scaleAspectFill
        twerk.layer.cornerRadius = 4
    }
}
