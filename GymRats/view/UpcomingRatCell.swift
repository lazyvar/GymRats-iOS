//
//  UpcomingRatCell.swift
//  GymRats
//
//  Created by Mack on 5/3/21.
//  Copyright © 2021 Mack Hasz. All rights reserved.
//

import UIKit

class UpcomingRatCell: UITableViewCell {
  @IBOutlet private weak var avatarView: UserImageView!

  @IBOutlet private weak var nameLabel: UILabel! {
    didSet {
      nameLabel.textColor = .primaryText
      nameLabel.font = .h4Bold
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    
    animatePress(true)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    animatePress(false)
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    
    animatePress(false)
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    selectionStyle = .none
  }
  
  static func configure(tableView: UITableView, indexPath: IndexPath, rat: Account) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: UpcomingRatCell.self, for: indexPath).apply {
      $0.nameLabel.text = rat.fullName
      $0.avatarView.load(rat)
    }
  }
}
