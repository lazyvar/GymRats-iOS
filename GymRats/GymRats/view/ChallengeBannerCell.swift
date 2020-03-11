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
  
  @IBOutlet weak var bg: UIView! {
    didSet {
      bg.backgroundColor = .foreground
      bg.layer.cornerRadius = 4
      bg.clipsToBounds = true
    }
  }
  
  @IBOutlet weak var bannerImageView: UIImageView! {
    didSet { bannerImageView.contentMode = .scaleAspectFill }
  }
}
