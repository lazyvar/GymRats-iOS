//
//  NoWorkoutsCell.swift
//  GymRats
//
//  Created by mack on 3/18/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class NoWorkoutsCell: UITableViewCell {
  @IBOutlet private weak var logWorkoutButton: PrimaryButton!
  private var onLogWorkout: (() -> Void)?
  
  @IBAction private func tappedLogWorkout(_ sender: Any) {
    onLogWorkout?()
  }
  
  static func configure(tableView: UITableView, indexPath: IndexPath, challenge: Challenge, onLogWorkout: @escaping () -> Void) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: NoWorkoutsCell.self, for: indexPath).apply {
      $0.onLogWorkout = onLogWorkout
      $0.selectionStyle = .none
      $0.logWorkoutButton.isHidden = challenge.isPast
    }
  }
}
