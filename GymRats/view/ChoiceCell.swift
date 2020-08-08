//
//  ChoiceCell.swift
//  GymRats
//
//  Created by mack on 4/7/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class ChoiceCell: UITableViewCell {
  @IBOutlet private weak var bigLabel: UILabel! {
    didSet {
      bigLabel.font = .h4Bold
      bigLabel.textColor = .primaryText
    }
  }
  
  @IBOutlet private weak var smallLabel: UILabel! {
    didSet {
      smallLabel.font = .body
      smallLabel.textColor = .primaryText
    }
  }
  
  @IBOutlet private weak var chevron: UIImageView! {
    didSet { chevron.tintColor = .primaryText }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    backgroundColor = .clear
    selectionStyle = .none
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
  
  static func configure(tableView: UITableView, indexPath: IndexPath, goal: Goal) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: ChoiceCell.self, for: indexPath).apply {
      $0.bigLabel.text = goal.title
      $0.smallLabel.text = goal.description
    }
  }

  static func configure(tableView: UITableView, indexPath: IndexPath, mode: ChallengeMode) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: ChoiceCell.self, for: indexPath).apply {
      $0.bigLabel.text = mode.title
      $0.smallLabel.text = mode.subtitle
    }
  }

  static func configure(tableView: UITableView, indexPath: IndexPath, choice: ChallengeBannerChoice) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: ChoiceCell.self, for: indexPath).apply {
      $0.bigLabel.text = choice.title
      $0.smallLabel.isHidden = true
    }
  }

  static func configureForChange(tableView: UITableView, indexPath: IndexPath, choice: ChallengeBannerChoice) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: ChoiceCell.self, for: indexPath).apply {
      $0.bigLabel.text = choice.titleForChange
      $0.smallLabel.isHidden = true
    }
  }
}
