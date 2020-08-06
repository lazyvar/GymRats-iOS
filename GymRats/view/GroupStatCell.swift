//
//  GroupStatCell.swift
//  GymRats
//
//  Created by mack on 8/5/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class GroupStatCell: UITableViewCell {
  @IBOutlet private weak var avatarView: UserImageView!
  @IBOutlet private weak var topLabel: UILabel! {
    didSet {
      topLabel.textColor = .primaryText
      topLabel.font = .sixteenBold
    }
  }
  
  @IBOutlet private weak var rightLabel: UILabel! {
    didSet {
      rightLabel.textColor = .primaryText
      rightLabel.font = .twenty
    }
  }

  @IBOutlet private weak var bottomLabel: UILabel! {
    didSet {
      bottomLabel.textColor = .primaryText
      bottomLabel.font = .body
    }
  }

  @IBOutlet private weak var iconImageView: UIImageView! {
    didSet {
      iconImageView.layer.cornerRadius = 21
      iconImageView.clipsToBounds = true
      iconImageView.backgroundColor = .divider
      iconImageView.tintColor = .primaryText
    }
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    
    avatarView.isHidden = true
    iconImageView.isHidden = true
    rightLabel.text = nil
  }
  
  static func configure(tableView: UITableView, indexPath: IndexPath, avatar: Avatar?, image: UIImage?, topLabel: String, bottomLabel: String, rightLabel: String?) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: GroupStatCell.self, for: indexPath).apply { cell in
      cell.topLabel.text = topLabel
      cell.bottomLabel.text = bottomLabel
      cell.rightLabel.text = rightLabel
      
      if let avatar = avatar {
        cell.avatarView.isHidden = false
        cell.avatarView.load(avatar)
      }
      
      if let image = image {
        cell.iconImageView.isHidden = false
        cell.iconImageView.image = image
      }
    }
  }
}
