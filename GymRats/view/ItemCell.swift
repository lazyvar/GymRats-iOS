//
//  ItemCell.swift
//  GymRats
//
//  Created by Mack on 6/1/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {
  @IBOutlet private weak var userImageView: UserImageView!
  @IBOutlet private weak var titleLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    userImageView.backgroundColor = .clear
    titleLabel.font = .bodyBold
    backgroundColor = .brand
    titleLabel.textColor = .white
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    userImageView.clear()
    titleLabel.text = nil
  }
  
  static func configure(tableView: UITableView, indexPath: IndexPath, challenge: Challenge) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: ItemCell.self, for: indexPath).apply {
      $0.userImageView.load(challenge)
      $0.titleLabel.text = challenge.name
    }
  }
}
