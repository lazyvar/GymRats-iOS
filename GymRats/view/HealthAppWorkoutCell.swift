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
      titleLabel.font = .h4Bold
    }
  }
  
  @IBOutlet private weak var descriptionLabel: UILabel! {
    didSet {
      descriptionLabel.textColor = .primaryText
      descriptionLabel.font = .body
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
      $0.titleLabel.text = workout.workoutActivityType.name
      $0.descriptionLabel.text = "\(Int(workout.duration / 60)) minutes - \(workout.startDate.toFormat("MMM d, yyyy h:mm a"))"
    }
  }
}
