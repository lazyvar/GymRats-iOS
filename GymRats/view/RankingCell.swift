//
//  RankingCell.swift
//  GymRats
//
//  Created by mack on 7/31/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class RankingCell: UITableViewCell {
  private static let formatter = NumberFormatter().apply { $0.numberStyle = .ordinal }
  
  var press: (() -> Void)?
  
  @IBOutlet private weak var nameLabel: UILabel! {
    didSet {
      nameLabel.textColor = .primaryText
      nameLabel.font = .sixteenBold
    }
  }
  
  @IBOutlet private weak var scoreLabel: UILabel! {
    didSet {
      scoreLabel.textColor = .primaryText
      scoreLabel.font = .body
    }
  }

  @IBOutlet private weak var avatar: UserImageView!
  @IBOutlet private weak var placeLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    
    selectionStyle = .none
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    placeLabel.isHidden = false
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

  static func configure(tableView: UITableView, indexPath: IndexPath, ranking: Ranking, place: Int, scoreBy: ScoreBy, press: @escaping () -> Void) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: RankingCell.self, for: indexPath).apply { cell in
      let ordinal = formatter.string(from: NSNumber(value: place))?.trimmingCharacters(in: .decimalDigits) ?? ""
      
      cell.press = press
      cell.avatar.load(ranking.account)
      cell.nameLabel.text = ranking.account.fullName
      cell.scoreLabel.text = "\(ranking.score) \(scoreBy.description)"
      cell.placeLabel.attributedText = NSMutableAttributedString().apply {
        $0.append(.init(string: "\(place)", attributes: [NSAttributedString.Key.font: UIFont.twenty]))
        $0.append(.init(string: ordinal, attributes: [NSAttributedString.Key.font: UIFont.body]))
      }
    }
  }
  
  static func configure(tableView: UITableView, indexPath: IndexPath, team: Team, press: @escaping () -> Void) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: RankingCell.self, for: indexPath).apply { cell in
      let memberCount = (team.members ?? []).count
      
      cell.press = press
      cell.avatar.load(team)
      cell.nameLabel.text = team.name
      cell.scoreLabel.text = "\(memberCount) member\(memberCount == 1 ? "" : "s")"
      cell.placeLabel.isHidden = true
    }
  }

  static func configure(tableView: UITableView, indexPath: IndexPath, ranking: Ranking, scoreBy: ScoreBy, press: @escaping () -> Void) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: RankingCell.self, for: indexPath).apply { cell in
      cell.press = press
      cell.avatar.load(ranking.account)
      cell.nameLabel.text = ranking.account.fullName
      cell.scoreLabel.text = "\(ranking.score) \(scoreBy.description)"
      cell.placeLabel.isHidden = true
    }
  }
}
