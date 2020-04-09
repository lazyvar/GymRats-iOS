//
//  NoWorkoutsCell.swift
//  GymRats
//
//  Created by mack on 3/18/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class NoWorkoutsCell: UITableViewCell {
  @IBOutlet weak var runnerImageView: UIImageView!
  @IBOutlet weak var label: UILabel! {
    didSet {
      label.textColor = .primaryText
      label.font = .h4
    }
  }

  static func configure(tableView: UITableView, indexPath: IndexPath, challenge: Challenge) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: NoWorkoutsCell.self, for: indexPath).apply {
      $0.selectionStyle = .none
    }
  }
}
