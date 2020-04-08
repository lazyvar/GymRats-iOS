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

    imageShadowView.alpha = 1
    workoutTitleLabel.text = nil
    workoutImageView.image = nil
    accountNameLabel.text = nil
    workoutImageView.kf.cancelDownloadTask()
  }
  
  static func skeleton(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueSkeletonCell(withType: WorkoutListCell.self, for: indexPath).apply {      
      print($0)
    }
  }

  static func configure(tableView: UITableView, indexPath: IndexPath, workout: Workout) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: WorkoutListCell.self, for: indexPath).apply { cell in
      cell.accountNameLabel.text = workout.account.fullName
      cell.workoutImageView.kf.setImage(with: URL(string: workout.photoUrl ?? ""), options: [.transition(.fade(0.2))]) { _, _, _, _ in
        UIView.animate(withDuration: 0.2) {
          cell.imageShadowView.alpha = 0
        }
      }
      cell.workoutTitleLabel.text = workout.title
      cell.accountImageView.load(avatarInfo: workout.account)
//      $0.timeLabel.text = "\(workout.createdAt.challengeTime)"
    }
  }
}
