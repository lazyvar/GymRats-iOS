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
        
        shadowView.isSkeletonable = true
        shadowView.startSkeletonAnimation()
        shadowView.showSkeleton()
        
        twerk.contentMode = .scaleAspectFill
        twerk.layer.cornerRadius = 4
        twerk.clipsToBounds = true
        accessoryType = .disclosureIndicator
        clipsToBounds = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        twerk.image = nil
        twerk.kf.cancelDownloadTask()
        shadowView.startSkeletonAnimation()
        shadowView.showSkeleton()
    }
}
