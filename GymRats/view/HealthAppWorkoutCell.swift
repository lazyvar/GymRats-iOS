//
//  HealthAppWorkoutCell.swift
//  GymRats
//
//  Created by mack on 5/4/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import HealthKit

class HealthAppWorkoutCell: UITableViewCell {
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.textColor = .primaryText
      titleLabel.font = .emphasis
    }
  }

  @IBOutlet private weak var descriptionLabel: UILabel! {
    didSet {
      descriptionLabel.textColor = .primaryText
      descriptionLabel.font = .details
    }
  }
  
  @IBOutlet weak var activityIconBackgroundView: UIView! {
    didSet {
      activityIconBackgroundView.backgroundColor = .brand
      activityIconBackgroundView.clipsToBounds = true
      activityIconBackgroundView.layer.cornerRadius = 22
    }
  }
  
  @IBOutlet weak var activityImageView: UIImageView! {
    didSet {
      activityImageView.layer.cornerRadius = 19
      activityImageView.clipsToBounds = true
      activityImageView.contentMode = .scaleAspectFill
    }
  }
  
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

  static func configure(tableView: UITableView, indexPath: IndexPath, workout: HKWorkout) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: HealthAppWorkoutCell.self, for: indexPath).apply {
      $0.activityImageView.image = workout.workoutActivityType.activityify.icon
      $0.titleLabel.text = workout.workoutActivityType.name
      
      if workout.startDate.in(region: .current).year == Date().in(region: .current).year {
        $0.descriptionLabel.text = "\(workout.startDate.in(region: .current).toFormat("EEEE, MMM d h:mm a")) | \(Int(workout.duration / 60)) minutes"
      } else {
        $0.descriptionLabel.text = "\(workout.startDate.in(region: .current).toFormat("EEEE, MMM d yyyy h:mm a")) | \(Int(workout.duration / 60)) minutes"
        
      }
    }
  }
}
