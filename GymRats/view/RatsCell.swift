//
//  RatsCell.swift
//  GymRats
//
//  Created by mack on 12/8/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

class RatsCell: UITableViewCell {
  @IBOutlet private weak var userImageView: UserImageView!
  @IBOutlet private weak var nameLabel: UILabel!
  @IBOutlet private weak var descLabel: UILabel!
  
  func configure(withHuman human: Account, score: String, scoredBy: ScoreBy) {
    userImageView.load(human)
    nameLabel.text = "\(human.fullName)"
    descLabel.text = "\(score) \(scoredBy.description)"
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    userImageView.clear()
  }
}
