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
  
  @IBOutlet private weak var durationLabelLabel: UILabel! {
    didSet {
      durationLabelLabel.textColor = .primaryText
      durationLabelLabel.font = .detailsBold
    }
  }
  
  @IBOutlet private weak var distanceLabelLabel: UILabel! {
    didSet {
      distanceLabelLabel.textColor = .primaryText
      distanceLabelLabel.font = .detailsBold
    }
  }
  
  @IBOutlet private weak var stepsLabelLabel: UILabel! {
    didSet {
      stepsLabelLabel.textColor = .primaryText
      stepsLabelLabel.font = .detailsBold
    }
  }
  
  @IBOutlet private weak var caloriesLabelLabel: UILabel! {
    didSet {
      caloriesLabelLabel.textColor = .primaryText
      caloriesLabelLabel.font = .detailsBold
    }
  }
  
  @IBOutlet private weak var pointsLabelLabel: UILabel! {
    didSet {
      pointsLabelLabel.textColor = .primaryText
      pointsLabelLabel.font = .detailsBold
    }
  }
  
  @IBOutlet private weak var dataStack: UIStackView!
  @IBOutlet private weak var firstStack: UIStackView!
  @IBOutlet private weak var secondStack: UIStackView!
  
  @IBOutlet private weak var workoutDescriptionLabel: UILabel! {
    didSet {
      workoutDescriptionLabel.textColor = .primaryText
      workoutDescriptionLabel.font = .body
    }
  }
  
  @IBOutlet private weak var workoutTitleLabel: UILabel! {
    didSet {
      workoutTitleLabel.textColor = .primaryText
      workoutTitleLabel.font = .h4Bold
    }
  }
  
  @IBOutlet private weak var dividerView: UIView! {
    didSet {
      dividerView.backgroundColor = .divider
    }
  }
    
  override func awakeFromNib() {
    super.awakeFromNib()

    selectionStyle = .none
    backgroundColor = .foreground
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    dataStack.isHidden = false
    dividerView.isHidden = false
    firstStack.isHidden = false
    secondStack.isHidden = false
    durationLabel.text = nil
    distanceLabel.text = nil
    stepsLabel.text = nil
    caloriesLabel.text = nil
    pointsLabel.text = nil
    durationLabelLabel.text = nil
    distanceLabelLabel.text = nil
    stepsLabelLabel.text = nil
    caloriesLabelLabel.text = nil
    pointsLabelLabel.text = nil
  }
  
  private func configureStacks(_ workout: Workout) {
    let possibleData: [(dataType: WorkoutData, value: String?)] = [
      (.duration, workout.duration?.stringify),
      (.distance, workout.distance),
      (.steps, workout.steps?.stringify),
      (.calories, workout.calories?.stringify),
      (.points, workout.points?.stringify),
    ]
      
    let data = possibleData.compactMap { data -> (dataType: WorkoutData, value: String)? in
      guard let value = data.value else { return nil }
          
      return (data.dataType, value)
    }

    for data in data.enumerated() {
      let dataType = data.element.dataType.rawValue.capitalized
      let dataValue = data.element.value
      
      switch data.offset {
      case 0:
        durationLabelLabel.text = dataType
        durationLabel.text = dataValue
      case 1:
        distanceLabelLabel.text = dataType
        distanceLabel.text = dataValue
      case 2:
        stepsLabelLabel.text = dataType
        stepsLabel.text = dataValue
      case 3:
        caloriesLabelLabel.text = dataType
        caloriesLabel.text = dataValue
      case 4:
        pointsLabelLabel.text = dataType
        pointsLabel.text = dataValue
      default: break
      }
    }
    
    if data.isEmpty {
      firstStack.isHidden = true
      secondStack.isHidden = true
      dataStack.isHidden = true
      dividerView.isHidden = true
    }
    
    if data.count < 4 {
      secondStack.isHidden = true
    }
  }

  static func configure(tableView: UITableView, indexPath: IndexPath, workout: Workout) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: WorkoutDetailsCell.self, for: indexPath).apply { cell in
      cell.workoutTitleLabel.text = workout.title
      cell.workoutDescriptionLabel.text = workout.description
      cell.configureStacks(workout)
    }
  }
}
