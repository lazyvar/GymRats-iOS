//
//  WorkoutDetailsCell.swift
//  GymRats
//
//  Created by mack on 4/9/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class WorkoutDetailsCell: UITableViewCell {
  enum WorkoutData: String, CaseIterable {
    case duration
    case distance
    case steps
    case calories
    case points
  }
  
  @IBOutlet private weak var healthAppImageView: UIImageView! {
    didSet {
      healthAppImageView.layer.borderWidth = 1
      healthAppImageView.clipsToBounds = true
      healthAppImageView.layer.cornerRadius = 4
      healthAppImageView.layer.borderColor = UIColor.background.cgColor
    }
  }
  
  @IBOutlet private weak var dataStack: UIStackView!
  
  @IBOutlet private weak var durationLabel: UILabel! {
    didSet {
      durationLabel.textColor = .primaryText
      durationLabel.font = .details
    }
  }
  
  @IBOutlet private weak var distanceLabel: UILabel! {
    didSet {
      distanceLabel.textColor = .primaryText
      distanceLabel.font = .details
    }
  }
  
  @IBOutlet private weak var stepsLabel: UILabel! {
    didSet {
      stepsLabel.textColor = .primaryText
      stepsLabel.font = .details
    }
  }
  
  @IBOutlet private weak var caloriesLabel: UILabel! {
    didSet {
      caloriesLabel.textColor = .primaryText
      caloriesLabel.font = .details
    }
  }
  
  @IBOutlet private weak var pointsLabel: UILabel! {
    didSet {
      pointsLabel.textColor = .primaryText
      pointsLabel.font = .details
    }
  }

  @IBOutlet private weak var appleHealthLabel: UILabel! {
    didSet {
      appleHealthLabel.textColor = .primaryText
      appleHealthLabel.font = .details
    }
  }

  @IBOutlet private weak var workoutDescriptionLabel: SmartLabel!
  
  @IBOutlet private weak var workoutTitleLabel: UILabel! {
    didSet {
      workoutTitleLabel.textColor = .primaryText
      workoutTitleLabel.font = .h4Bold
    }
  }
  
  @IBOutlet private weak var appleHealthStack: UIStackView!
  
  override func awakeFromNib() {
    super.awakeFromNib()

    selectionStyle = .none
    backgroundColor = .foreground
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    durationLabel.text = nil
    distanceLabel.text = nil
    stepsLabel.text = nil
    caloriesLabel.text = nil
    pointsLabel.text = nil
    durationLabel.isHidden = true
    distanceLabel.isHidden = true
    stepsLabel.isHidden = true
    caloriesLabel.isHidden = true
    pointsLabel.isHidden = true
    appleHealthStack.isHidden = true
  }

  private func makeGood(_ workout: Workout) {
    durationLabel.isHidden = workout.duration == nil
    distanceLabel.isHidden = workout.distance == nil
    stepsLabel.isHidden = workout.steps == nil
    caloriesLabel.isHidden = workout.calories == nil
    pointsLabel.isHidden = workout.points == nil
  
    if let duration = workout.duration {
      durationLabel.text = "Active for \(duration) minutes"
    }
    
    if let distance = workout.distance {
      distanceLabel.text = "Traveled \(distance) miles"
    }
    
    if let steps = workout.steps {
      stepsLabel.text = "Strode \(steps) steps"
    }
    
    if let calories = workout.calories {
      caloriesLabel.text = "Burned \(calories) calories"
    }
    
    if let points = workout.points {
      pointsLabel.text = "Earned \(points) points"
    }
    
    if let activity = workout.activityType, let deviceName = workout.appleDeviceName {
      appleHealthStack.isHidden = false
      appleHealthLabel.text = "\(activity.title.capitalized) | \(deviceName)"
    } else {
      appleHealthStack.isHidden = true
    }
    
    if workout.duration == nil && workout.distance == nil && workout.steps == nil && workout.calories == nil && workout.points == nil {
      dataStack.isHidden = true
    } else {
      dataStack.isHidden = false
    }
  }
  
  static func configure(tableView: UITableView, indexPath: IndexPath, workout: Workout) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: WorkoutDetailsCell.self, for: indexPath).apply { cell in
      cell.workoutTitleLabel.text = workout.title
      cell.workoutDescriptionLabel.text = workout.description
      cell.makeGood(workout)
    }
  }
}
