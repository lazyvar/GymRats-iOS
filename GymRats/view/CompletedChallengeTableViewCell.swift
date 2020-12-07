//
//  CompletedChallengeTableViewCell.swift
//  GymRats
//
//  Created by mack on 12/7/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class CompletedChallengeTableViewCell: UITableViewCell {
  @IBOutlet private weak var avatarView: UserImageView!
  @IBOutlet private weak var descriptionLabel: UILabel! {
    didSet {
      descriptionLabel.textColor = .primaryText
      descriptionLabel.font = .details
    }
  }

  @IBOutlet private weak var titleView: UILabel! {
    didSet {
      titleView.textColor = .primaryText
      titleView.font = .emphasis
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
  
  func configure(_ challenge: Challenge) {
    titleView.text = challenge.name
    avatarView.load(challenge)
    descriptionLabel.text = challenge.daysLeft
  }
}
