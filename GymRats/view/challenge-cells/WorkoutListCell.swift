//
//  WorkoutListCell.swift
//  GymRats
//
//  Created by Mack on 9/8/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import Kingfisher
import SkeletonView

class WorkoutListCell: UITableViewCell {
  @IBOutlet private weak var bgView: UIView! {
    didSet {
      bgView.backgroundColor = .foreground
      bgView.layer.cornerRadius = 4
      bgView.clipsToBounds = true
    }
  }
  
  @IBOutlet private weak var imageShadowView: UIView! {
    didSet {
      imageShadowView.isSkeletonable = true
      imageShadowView.showAnimatedSkeleton()
    }
  }
  
  @IBOutlet private weak var workoutImageView: UIImageView! {
    didSet {
      workoutImageView.contentMode = .scaleAspectFill
      workoutImageView.backgroundColor = .clear
      workoutImageView.isSkeletonable = false
    }
  }
  
  @IBOutlet private weak var workoutTitleLabel: UILabel! {
    didSet {
      workoutTitleLabel.textColor = .primaryText
      workoutTitleLabel.font = .body
    }
  }
  
  @IBOutlet private weak var accountNameLabel: UILabel! {
    didSet {
      accountNameLabel.textColor = .primaryText
      accountNameLabel.font = .body
    }
  }
  @IBOutlet private weak var timeLabel: UILabel! {
    didSet {
      timeLabel.textColor = .primaryText
      timeLabel.font = .details
    }
  }
  
  @IBOutlet private weak var workoutImageWidth: NSLayoutConstraint!
  @IBOutlet private weak var accountImageView: UserImageView!
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    
    animatePress(true)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    animatePress(false)
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    
    animatePress(false)
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    
    selectionStyle = .none
  }

  override func prepareForReuse() {
    super.prepareForReuse()

    workoutImageWidth.constant = 64
    workoutTitleLabel.text = nil
    workoutImageView.image = nil
    accountNameLabel.text = nil
    workoutImageView.kf.cancelDownloadTask()
  }
  
  static func skeleton(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueSkeletonCell(withType: WorkoutListCell.self, for: indexPath).apply {      
      $0.accountNameLabel.isSkeletonable = true
      $0.workoutImageView.isSkeletonable = true
      $0.workoutTitleLabel.isSkeletonable = true
      $0.accountImageView.isSkeletonable = true
      $0.timeLabel.isSkeletonable = true

      $0.accountNameLabel.linesCornerRadius = 2
      $0.workoutTitleLabel.linesCornerRadius = 2
      $0.timeLabel.linesCornerRadius = 2
      $0.accountImageView.layer.cornerRadius = 10
      $0.accountImageView.clipsToBounds = true
      
      if let width = $0.accountNameLabel.constraints.first(where: { constraint -> Bool in
        return constraint.firstAttribute == .width
      }) {
        $0.accountNameLabel.removeConstraint(width)
      }

      if let width = $0.workoutTitleLabel.constraints.first(where: { constraint -> Bool in
        return constraint.firstAttribute == .width
      }) {
        $0.workoutTitleLabel.removeConstraint(width)
      }

      $0.accountNameLabel.constrainWidth(CGFloat.random(in: 55...125))
      $0.workoutTitleLabel.constrainWidth(CGFloat.random(in: 95...200))

      $0.accountNameLabel.showAnimatedSkeleton()
      $0.workoutImageView.showAnimatedSkeleton()
      $0.workoutTitleLabel.showAnimatedSkeleton()
      $0.accountImageView.showAnimatedSkeleton()
      $0.timeLabel.showAnimatedSkeleton()
    }
  }

  static func configure(tableView: UITableView, indexPath: IndexPath, workout: Workout) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: WorkoutListCell.self, for: indexPath).apply {
      $0.accountNameLabel.text = workout.account.fullName
      $0.workoutImageView.kf.setImage(with: URL(string: workout.photoUrl ?? ""), options: [.transition(.fade(0.2))])
      $0.workoutTitleLabel.text = workout.title
      $0.accountImageView.load(workout.account)
      $0.timeLabel.text = "\(workout.createdAt.challengeTime)"
    }
  }
}
