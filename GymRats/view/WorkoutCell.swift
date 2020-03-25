//
//  WorkoutCell.swift
//  GymRats
//
//  Created by Mack on 9/8/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import Kingfisher

class WorkoutCell: UITableViewCell {
  @IBOutlet weak var detailsLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel! {
    didSet {
      timeLabel.textColor = .secondaryLblColor
    }
  }
  @IBOutlet weak var userImageView: UserImageView!
  @IBOutlet weak var descriptionLabel: UILabel!
    
  @IBOutlet weak var chevronView: UIImageView! {
    didSet {
      chevronView.tintColor = .chevron
    }
  }
  
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
  
  @IBOutlet weak var clockImageView: UIImageView! {
    didSet {
      clockImageView.tintColor = .secondaryLblColor
    }
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
    
    detailsLabel.linesCornerRadius = 4
    titleLabel.linesCornerRadius = 4
    timeLabel.linesCornerRadius = 4
    descriptionLabel.linesCornerRadius = 4
    userImageView.isHidden = true
    
    titleLabel.clipsToBounds = true
    descriptionLabel.clipsToBounds = true
    
    clipsToBounds = false
  }
      
  override func prepareForReuse() {
    super.prepareForReuse()
    
    descriptionLabel.text = nil
    userImageView.imageView.image = nil
    timeLabel.text = nil
    titleLabel.text = nil
    detailsLabel.text = nil
    workoutImageView.image = nil
    workoutImageView.kf.cancelDownloadTask()
    shadowView.startSkeletonAnimation()
    shadowView.showSkeleton()
  }
  
  static func skeleton(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueSkeletonCell(withType: WorkoutCell.self, for: indexPath).apply {      
      $0.detailsLabel.isSkeletonable = true
      $0.titleLabel.isSkeletonable = true
      $0.timeLabel.isSkeletonable = true
      $0.descriptionLabel.isSkeletonable = true
      $0.clockImageView.isSkeletonable = true
      $0.userImageView.isSkeletonable = true

      $0.detailsLabel.showAnimatedSkeleton()
      $0.titleLabel.showAnimatedSkeleton()
      $0.timeLabel.showAnimatedSkeleton()
      $0.descriptionLabel.showAnimatedSkeleton()
      $0.clockImageView.showAnimatedSkeleton()
      $0.detailsLabel.showAnimatedSkeleton()
      $0.userImageView.showAnimatedSkeleton()
      
      $0.titleLabel.constrainWidth(CGFloat.random(in: 30...70))
      $0.descriptionLabel.constrainWidth(CGFloat.random(in: 30...70))
    }
  }

  static func configure(tableView: UITableView, indexPath: IndexPath, workout: Workout) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: WorkoutCell.self, for: indexPath).apply {
      $0.userImageView.isHidden = false

      $0.descriptionLabel.text = workout.description
      $0.workoutImageView.kf.setImage(with: URL(string: workout.photoUrl ?? ""), options: [.transition(.fade(0.2))])
      $0.titleLabel.text = workout.title
      $0.detailsLabel.text = workout.account.fullName
      $0.userImageView.load(avatarInfo: workout.account)
      $0.timeLabel.text = "\(workout.createdAt.challengeTime)"
    }
  }
}
