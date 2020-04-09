//
//  WorkoutAccountCell.swift
//  GymRats
//
//  Created by mack on 4/9/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class WorkoutAccountCell: UITableViewCell {
  @IBOutlet private weak var accountImageView: UserImageView!

  @IBOutlet private weak var timeLabel: UILabel! {
    didSet {
      timeLabel.textColor = .primaryText
      timeLabel.font = .details
    }
  }
  
  @IBOutlet private weak var accountNameLabel: UILabel! {
    didSet {
      accountNameLabel.textColor = .primaryText
      accountNameLabel.font = .body
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    accountImageView.clear()
    accountNameLabel.text = nil
    timeLabel.text = nil
  }

  static func configure(tableView: UITableView, indexPath: IndexPath, workout: Workout) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: WorkoutAccountCell.self, for: indexPath).apply { cell in
      cell.accountNameLabel.text = workout.account.fullName
      cell.accountImageView.load(workout.account)
      cell.timeLabel.text = "\(workout.createdAt.challengeTime)"
    }
  }
}
