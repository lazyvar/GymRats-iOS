//
//  FullLeaderboardCell.swift
//  GymRats
//
//  Created by mack on 8/4/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class FullLeaderboardCell: UITableViewCell {
  var press: (() -> Void)?
  
  @IBOutlet private weak var awardLabel: UIImageView! {
    didSet {
      awardLabel.layer.cornerRadius = 21
      awardLabel.clipsToBounds = true
      awardLabel.backgroundColor = .divider
      awardLabel.tintColor = .primaryText
    }
  }
  
  @IBOutlet private weak var leaderboardLabel: UILabel! {
    didSet {
      leaderboardLabel.font = .h4
      leaderboardLabel.textColor = .primaryText
    }
  }
  
  @IBOutlet private weak var chevron: UIImageView! {
    didSet {
      chevron.tintColor = .primaryText
    }
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    
    animatePress(true)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    press?()
    animatePress(false)
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    
    animatePress(false)
  }

  static func configure(tableView: UITableView, indexPath: IndexPath, press: @escaping () -> Void) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: FullLeaderboardCell.self, for: indexPath).apply { cell in
      cell.press = press
    }
  }
}
