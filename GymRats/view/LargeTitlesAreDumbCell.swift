//
//  LargeTitlesAreDumbCell.swift
//  GymRats
//
//  Created by mack on 8/8/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class LargeTitlesAreDumbCell: UITableViewCell {
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.textColor = .primaryText
      titleLabel.font = .title
    }
  }
  
  static func configure(tableView: UITableView, indexPath: IndexPath, challenge: Challenge) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: LargeTitlesAreDumbCell.self, for: indexPath).apply {
      $0.titleLabel.text = challenge.name
    }
  }
}
