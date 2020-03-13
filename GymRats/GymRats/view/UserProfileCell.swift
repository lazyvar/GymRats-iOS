//
//  UserProfileCell.swift
//  GymRats
//
//  Created by Mack on 6/1/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

class UserProfileCell: UITableViewCell {
  @IBOutlet weak var userImageView: UserImageView!
  @IBOutlet weak var usernameLabel: UILabel!
    
  override func awakeFromNib() {
    super.awakeFromNib()
    
    userImageView.backgroundColor = .clear
    backgroundColor = .brand
  }
  
  static func configure(tableView: UITableView, indexPath: IndexPath, account: Account) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: UserProfileCell.self, for: indexPath).apply {
      $0.userImageView.skeletonLoad(avatarInfo: account)
      $0.usernameLabel.text = account.fullName
    }
  }
}
