//
//  ChallengeCompleteDescriptionCell.swift
//  GymRats
//
//  Created by mack on 7/31/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class ChallengeCompleteDescriptionCell: UITableViewCell {
  @IBOutlet private weak var label: UILabel! {
    didSet {
      label.font = .body
      label.textColor = .primaryText
    }
  }
  
  @IBOutlet private weak var complete: UILabel! {
    didSet {
      complete.font = .h4Bold
      complete.textColor = .primaryText
    }
  }
  
  static func configure(tableView: UITableView, indexPath: IndexPath, description: NSAttributedString) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: ChallengeCompleteDescriptionCell.self, for: indexPath).apply {
      $0.label.attributedText = description
    }
  }
}
