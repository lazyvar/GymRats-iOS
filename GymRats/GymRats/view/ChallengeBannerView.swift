//
//  ChallengeBannerView.swift
//  GymRats
//
//  Created by mack on 3/11/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class ChallengeBannerView: XibView {
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
