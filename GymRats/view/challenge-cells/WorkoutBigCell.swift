//
//  WorkoutBigCell.swift
//  GymRats
//
//  Created by mack on 4/8/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class WorkoutBigCell: UITableViewCell {
  @IBOutlet private weak var workoutImageView: UIImageView! {
    didSet {
      workoutImageView.contentMode = .scaleAspectFill
      workoutImageView.backgroundColor = .clear
      workoutImageView.layer.cornerRadius = 4
      workoutImageView.clipsToBounds = true
      workoutImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
  }
  
  @IBOutlet private weak var imageSkeletonView: UIView! {
    didSet {
      imageSkeletonView.isSkeletonable = true
      imageSkeletonView.clipsToBounds = true
      imageSkeletonView.showAnimatedSkeleton()
      imageSkeletonView.layer.cornerRadius = 4
      imageSkeletonView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
  }
  
  @IBOutlet private weak var timeLabel: UILabel! {
    didSet {
      timeLabel.textColor = .primaryText
      timeLabel.font = .details
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

  @IBOutlet private weak var bgView: UIView! {
    didSet {
      bgView.backgroundColor = .clear
    }
  }
  
  @IBOutlet private weak var accountImageView: UserImageView!
  @IBOutlet private weak var workoutImageBackground: UIView!
  
  private var shadowLayer: CAShapeLayer!
  
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

    backgroundColor = .clear
    workoutImageBackground.isHidden = false
    workoutTitleLabel.text = nil
    workoutImageView.image = nil
    accountNameLabel.text = nil
    workoutImageView.kf.cancelDownloadTask()
  }

  override func layoutIfNeeded() {
    super.layoutIfNeeded()
    
    if self.shadowLayer == nil {
      self.shadowLayer = CAShapeLayer()
      self.shadowLayer.path = UIBezierPath(roundedRect: self.bgView.bounds, cornerRadius: 4).cgPath
      self.shadowLayer.fillColor = UIColor.foreground.cgColor

      self.shadowLayer.shadowColor = UIColor.shadow.cgColor
      self.shadowLayer.shadowPath = self.shadowLayer.path
      self.shadowLayer.shadowOffset = CGSize(width: 0, height: 0)
      self.shadowLayer.shadowOpacity = 1
      self.shadowLayer.shadowRadius = 2

      self.bgView.layer.insertSublayer(self.shadowLayer, at: 0)
    }
  }
  
  static func skeleton(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueSkeletonCell(withType: WorkoutBigCell.self, for: indexPath).apply {
      $0.accountNameLabel.isSkeletonable = true
      $0.workoutTitleLabel.isSkeletonable = true
      $0.accountImageView.isSkeletonable = true

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
      $0.workoutTitleLabel.showAnimatedSkeleton()
      $0.accountImageView.showAnimatedSkeleton()
      $0.timeLabel.showAnimatedSkeleton()
    }
  }

  static func configure(tableView: UITableView, indexPath: IndexPath, workout: Workout) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: WorkoutBigCell.self, for: indexPath).apply {
      $0.accountNameLabel.text = workout.account.fullName
      $0.workoutTitleLabel.text = workout.title
      $0.accountImageView.load(workout.account)
      $0.timeLabel.text = "\(workout.occurredAt.challengeTime)"

      if let photo = workout.thumbnailUrl, let url = URL(string: photo) {
        $0.workoutImageView.kf.setImage(with: url, options: [.transition(.fade(0.2)), .forceTransition])
      } else {
        $0.workoutImageBackground.isHidden = true
      }
    }
  }
}
