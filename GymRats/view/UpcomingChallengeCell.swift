//
//  UpcomingChallengeCell.swift
//  GymRats
//
//  Created by Mack on 5/3/21.
//  Copyright © 2021 Mack Hasz. All rights reserved.
//

import UIKit

class UpcomingChallengeCell: UITableViewCell {
  @IBOutlet private weak var bannerImageView: UIImageView! {
    didSet {
      bannerImageView.contentMode = .scaleAspectFill
      bannerImageView.clipsToBounds = true
      bannerImageView.layer.cornerRadius = 4
      bannerImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
  }

  @IBOutlet private weak var calendarImageView: UIImageView! {
    didSet {
      calendarImageView.tintColor = .primaryText
    }
  }
  
  @IBOutlet private weak var clockImageView: UIImageView! {
    didSet {
      clockImageView.tintColor = .primaryText
    }
  }
  
  @IBOutlet private weak var codeImageView: UIImageView! {
    didSet {
      codeImageView.tintColor = .primaryText
    }
  }
  
  @IBOutlet private weak var starImageView: UIImageView! {
    didSet { starImageView.tintColor = .primaryText }
  }
  
  @IBOutlet private weak var clipboardImageView: UIImageView! {
    didSet { clipboardImageView.tintColor = .primaryText }
  }
  
  @IBOutlet private weak var durationLabel: UILabel! {
    didSet {
      durationLabel.textColor = .primaryText
      durationLabel.font = .body
    }
  }
  
  @IBOutlet private weak var startsLabel: UILabel! {
     didSet {
       startsLabel.textColor = .primaryText
       startsLabel.font = .body
     }
   }
  
  @IBOutlet private weak var scoreByLabel: UILabel! {
    didSet {
      scoreByLabel.font = .body
      scoreByLabel.textColor = .primaryText
    }
  }
  
  @IBOutlet weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .h4Bold
      titleLabel.textColor = .primaryText
    }
  }
  
  @IBOutlet weak var contentLabel: UILabel! {
    didSet {
      contentLabel.font = .body
      contentLabel.textColor = .primaryText
    }
  }

  @IBOutlet private weak var descriptionLabel: SmartLabel!
  @IBOutlet private weak var descriptionStackView: UIStackView!
  @IBOutlet private weak var codeLabel: SmartLabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    selectionStyle = .none
  }
  
  static func configure(tableView: UITableView, indexPath: IndexPath, challenge: Challenge) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: UpcomingChallengeCell.self, for: indexPath).apply {
      let date: String = {
        if challenge.startDate.serverDateIsToday {
          return "today"
        } else if challenge.startDate.serverDateIsYesterday {
          return "yesterday"
        } else if challenge.startDate.serverDateIsTomorrow {
          return "tomorrow"
        } else {
          return challenge.startDate.in(region: .UTC).toFormat("MMMM d")
        }
      }()
      
      $0.isUserInteractionEnabled = true
      $0.scoreByLabel.text = "Scored by most \(challenge.scoreBy.display.lowercased())"
      $0.descriptionStackView.isHidden = challenge.description == nil || challenge.description == ""
      $0.descriptionLabel.text = challenge.description
      $0.durationLabel.text = "Spans \(challenge.days.count) days"
      $0.startsLabel.text = "Starts \(date)"
      $0.codeLabel.text = challenge.code
      
      if let photo = challenge.profilePictureUrl, let url = URL(string: photo) {
        $0.bannerImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
      } else {
        $0.bannerImageView.isHidden = true
      }
    }
  }
}
