//
//  WorkoutCell.swift
//  GymRats
//
//  Created by Mack on 9/8/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

class WorkoutCell: UITableViewCell {
  @IBOutlet weak var detailsLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var userImageView: UserImageView!
  @IBOutlet weak var descriptionLabel: UILabel!
    
  @IBOutlet weak var workoutImageView: UIImageView! {
    didSet {
      workoutImageView.contentMode = .scaleAspectFill
      workoutImageView.layer.cornerRadius = 4
      workoutImageView.clipsToBounds = true
    }
  }
  
  @IBOutlet weak var bg: UIView! {
    didSet { bg.layer.cornerRadius = 4 }
  }
  
  @IBOutlet weak var shadowView: UIView! {
    didSet {
      shadowView.layer.cornerRadius = 4
      shadowView.clipsToBounds = true
      shadowView.isSkeletonable = true
      shadowView.startSkeletonAnimation()
      shadowView.showSkeleton()
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()

    clipsToBounds = false
  }
      
  override func prepareForReuse() {
    super.prepareForReuse()
    
    workoutImageView.image = nil
    workoutImageView.kf.cancelDownloadTask()
    shadowView.startSkeletonAnimation()
    shadowView.showSkeleton()
  }
}
