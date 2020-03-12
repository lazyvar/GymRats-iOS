//
//  ChallengeBannerCell.swift
//  GymRats
//
//  Created by Mack on 9/8/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

class ChallengeBannerCell: UITableViewCell {
  @IBOutlet weak var calendarStackView: UIStackView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var membersLabel: UILabel!
  @IBOutlet weak var calendarLabel: UILabel!
  @IBOutlet weak var activityLabel: UILabel!
  @IBOutlet weak var pictureHeight: NSLayoutConstraint!
  @IBOutlet weak var bannerImageView: UIImageView!
  
  @IBOutlet weak var bg: UIView! {
    didSet {
      bg.backgroundColor = .foreground
      bg.layer.cornerRadius = 4
      bg.clipsToBounds = true
    }
  }
  
  static func configure(tableView: UITableView, indexPath: IndexPath, challenge: Challenge, members: [Account], workouts: [Workout]) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: ChallengeBannerCell.self, for: indexPath).apply {
      let skeletonView = UIView()
      skeletonView.isSkeletonable = true
      skeletonView.showAnimatedSkeleton()
      skeletonView.showSkeleton()
      
      $0.titleLabel.text = challenge.name
      
      if let pic = challenge.pictureUrl {
        $0.bannerImageView.kf.setImage(with: URL(string: pic)!, placeholder: skeletonView, options: [.transition(.fade(0.2))])
        $0.pictureHeight.constant = 150
      } else {
        $0.pictureHeight.constant = 0
      }
      
      $0.selectionStyle = .none
      
      if members.count == 0 {
        $0.membersLabel.text = "-\nmembers"
      } else if members.count == 1 {
        $0.membersLabel.text = "Solo\nchallenge"
      } else {
        $0.membersLabel.text = "\(members.count)\nmembers"
      }

      if workouts.count == 0 {
        $0.activityLabel.text = "-\nworkouts"
      } else if workouts.count == 1 {
        $0.activityLabel.text = "1\nworkout"
      } else {
        $0.activityLabel.text = "\(workouts.count)\nworkouts"
      }

      $0.calendarLabel.text = {
        let daysLeft = challenge.daysLeft.split(separator: " ")
        let first = daysLeft[0]
        let rest = daysLeft[daysLeft.startIndex+1..<daysLeft.endIndex].joined(separator: " ")
        
        return [String(first), rest].joined(separator: "\n")
      }()
    }
  }
}
