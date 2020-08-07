//
//  NoWorkoutsCell.swift
//  GymRats
//
//  Created by mack on 3/18/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class NoWorkoutsCell: UITableViewCell {
  @IBOutlet private weak var labelizer: UILabel! {
    didSet {
      labelizer.textColor = .primaryText
      labelizer.font = .body
    }
  }
  
  static func configure(tableView: UITableView, indexPath: IndexPath, challenge: Challenge) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: NoWorkoutsCell.self, for: indexPath).apply {
      $0.selectionStyle = .none
    }
  }
}
