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

  static func configure(tableView: UITableView, indexPath: IndexPath, workout: Workout) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: WorkoutCell.self, for: indexPath).apply {
      $0.descriptionLabel.text = workout.description
      $0.workoutImageView.kf.setImage(with: URL(string: workout.photoUrl ?? ""), options: [.transition(.fade(0.2))])
      $0.titleLabel.text = workout.title
      $0.detailsLabel.text = workout.account.fullName
      $0.userImageView.load(avatarInfo: workout.account)
      $0.timeLabel.text = "\(workout.createdAt.challengeTime)"
    }
  }
}
