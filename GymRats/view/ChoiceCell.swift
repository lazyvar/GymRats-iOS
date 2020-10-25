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
  
  @IBOutlet weak var heightConstraint: NSLayoutConstraint!
  
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
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    bigLabel.font = .h4Bold
    heightConstraint.constant = 80
  }
  
  private func makeOneLine() {
    heightConstraint.constant = 60
    smallLabel.isHidden = true
    bigLabel.font = .h4
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
      $0.makeOneLine()
    }
  }

  static func configure(tableView: UITableView, indexPath: IndexPath, title: String) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: ChoiceCell.self, for: indexPath).apply {
      $0.bigLabel.text = title
      $0.makeOneLine()
    }
  }

  static func configure(tableView: UITableView, indexPath: IndexPath, choice: EnableTeamsChoice) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: ChoiceCell.self, for: indexPath).apply {
      $0.bigLabel.text = choice.title
      $0.makeOneLine()
    }
  }

  static func configureForChange(tableView: UITableView, indexPath: IndexPath, choice: ChallengeBannerChoice) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: ChoiceCell.self, for: indexPath).apply {
      $0.bigLabel.text = choice.titleForChange
      $0.makeOneLine()
    }
  }
}
