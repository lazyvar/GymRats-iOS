//
//  ChallengeDetailsHeader.swift
//  GymRats
//
//  Created by mack on 8/4/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class ChallengeDetailsHeader: UITableViewCell {
  @IBOutlet private weak var barBackground: UIView! {
    didSet {
      barBackground.backgroundColor = .divider
      barBackground.clipsToBounds = true
      barBackground.layer.cornerRadius = 2
    }
  }

  @IBOutlet private weak var bar: UIView! {
    didSet {
      bar.backgroundColor = .brand
      bar.clipsToBounds = true
      bar.layer.cornerRadius = 2
    }
  }
  
  @IBOutlet private weak var codeThing: UIImageView! {
    didSet {
      codeThing.tintColor = .primaryText
    }
  }

  @IBOutlet private weak var codeLabel: SmartLabel! {
    didSet {
      codeLabel.tapToCopy()
    }
  }
  
  @IBOutlet private weak var barMultiplier: NSLayoutConstraint!
  @IBOutlet private weak var descriptionLabel: SmartLabel!
  
  @IBOutlet private weak var endDateLabel: UILabel! {
    didSet {
      endDateLabel.textColor = .primaryText
      endDateLabel.font = .proRoundedRegular(size: 10)
    }
  }
  
  @IBOutlet private weak var startDateLabel: UILabel! {
    didSet {
      startDateLabel.textColor = .primaryText
      startDateLabel.font = .proRoundedRegular(size: 10)
    }
  }
  
  static func configure(tableView: UITableView, indexPath: IndexPath, challenge: Challenge) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: ChallengeDetailsHeader.self, for: indexPath).apply { cell in
      cell.startDateLabel.attributedText = NSMutableAttributedString().apply {
        $0.append(.init(string: "Started ", attributes: [NSAttributedString.Key.font: UIFont.proRoundedBold(size: 10)]))
        $0.append(.init(string: "\(challenge.startDate.toFormat("MMM d, yyyy"))", attributes: [NSAttributedString.Key.font: UIFont.proRoundedRegular(size: 10)]))
      }

      if challenge.isPast {
        cell.endDateLabel.attributedText = NSMutableAttributedString().apply {
          $0.append(.init(string: "Completed ", attributes: [NSAttributedString.Key.font: UIFont.proRoundedBold(size: 10)]))
          $0.append(.init(string: "\(challenge.endDate.toFormat("MMM d, yyyy"))", attributes: [NSAttributedString.Key.font: UIFont.proRoundedRegular(size: 10)]))
        }
      } else {
        cell.endDateLabel.attributedText = NSMutableAttributedString().apply {
          $0.append(.init(string: "Finishes ", attributes: [NSAttributedString.Key.font: UIFont.proRoundedBold(size: 10)]))
          $0.append(.init(string: "\(challenge.endDate.toFormat("MMM d, yyyy"))", attributes: [NSAttributedString.Key.font: UIFont.proRoundedRegular(size: 10)]))
        }
      }
      
      cell.codeLabel.text = challenge.code
      cell.descriptionLabel.text = challenge.description
      
      if challenge.isActive {
        let diff = CGFloat(challenge.days.count) / CGFloat(challenge.allDays.count + 1)
        let newConstraint = cell.barMultiplier.constraintWithMultiplier(diff)
        
        cell.barBackground.removeConstraint(cell.barMultiplier)
        cell.barBackground.addConstraint(newConstraint)
        cell.barBackground.layoutIfNeeded()
        
        cell.barMultiplier = newConstraint
      }
    }
  }
}

extension NSLayoutConstraint {
  func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
    return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
  }
}
