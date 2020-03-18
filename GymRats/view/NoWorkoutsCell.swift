//
//  NoWorkoutsCell.swift
//  GymRats
//
//  Created by mack on 3/18/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class NoWorkoutsCell: UITableViewCell {
  private var onLogWorkout: (() -> Void)?
  
  @IBAction private func tappedLogWorkout(_ sender: Any) {
    onLogWorkout?()
  }
  
  static func configure(tableView: UITableView, indexPath: IndexPath, onLogWorkout: @escaping () -> Void) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: NoWorkoutsCell.self, for: indexPath).apply {
      $0.onLogWorkout = onLogWorkout
      $0.selectionStyle = .none
    }
  }
}
