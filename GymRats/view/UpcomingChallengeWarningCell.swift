//
//  UpcomingChallengeWarningCell.swift
//  GymRats
//
//  Created by Mack on 5/3/21.
//  Copyright © 2021 Mack Hasz. All rights reserved.
//

import UIKit

class UpcomingChallengeWarningCell: UITableViewCell {
  @IBOutlet weak var spookyView: SpookyView! {
    didSet {
//      spookyView.spookyColor = .warning
    }
  }
  
  @IBOutlet weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .h4Bold
      titleLabel.textColor = .primaryText
    }
  }
  
  @IBOutlet weak var contentLabel: UILabel! {
    didSet {
      contentLabel.font = .body
      contentLabel.textColor = .primaryText
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    selectionStyle = .none
  }

  static func configure(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: UpcomingChallengeWarningCell.self, for: indexPath)
    }
}
