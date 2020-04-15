//
//  ChallengeBannerCell.swift
//  GymRats
//
//  Created by Mack on 9/8/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

class ChallengeBannerCell: UITableViewCell {
  @IBOutlet private weak var calendarStackView: UIStackView!
  @IBOutlet private weak var pictureHeight: NSLayoutConstraint!
  
  @IBOutlet private weak var bannerImageView: UIImageView! {
    didSet {
      bannerImageView.contentMode = .scaleAspectFill
      bannerImageView.layer.cornerRadius = 4
      bannerImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
  }
  
  @IBOutlet private weak var bg: UIView! {
    didSet {
      bg.backgroundColor = .clear
    }
  }
  
  @IBOutlet private weak var leaderAvatar: UserImageView!
  @IBOutlet private weak var leaderLabel: UILabel!
  @IBOutlet private weak var currentAccountAvatar: UserImageView!
  @IBOutlet private weak var currentAccountLabel: UILabel!
  
  @IBOutlet weak var calendarLabel: UILabel!
  
  private var shadowLayer: CAShapeLayer!

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

  override func layoutIfNeeded() {
    super.layoutIfNeeded()
    
    if self.shadowLayer == nil {
      self.shadowLayer = CAShapeLayer()
      self.shadowLayer.path = UIBezierPath(roundedRect: self.bg.bounds, cornerRadius: 4).cgPath
      self.shadowLayer.fillColor = UIColor.foreground.cgColor

      self.shadowLayer.shadowColor = UIColor.shadow.cgColor
      self.shadowLayer.shadowPath = self.shadowLayer.path
      self.shadowLayer.shadowOffset = CGSize(width: 0, height: 0)
      self.shadowLayer.shadowOpacity = 1
      self.shadowLayer.shadowRadius = 2

      self.bg.layer.insertSublayer(self.shadowLayer, at: 0)
    }
  }

  static func configure(tableView: UITableView, indexPath: IndexPath, challenge: Challenge, challengeInfo: ChallengeInfo) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: ChallengeBannerCell.self, for: indexPath).apply {
      let skeletonView = UIView()
      skeletonView.isSkeletonable = true
      skeletonView.showAnimatedSkeleton()
      skeletonView.showSkeleton()
      
      if let pic = challenge.profilePictureUrl {
        $0.bannerImageView.kf.setImage(with: URL(string: pic)!, placeholder: skeletonView, options: [.transition(.fade(0.2))])
        $0.pictureHeight.constant = 150
      } else {
        $0.pictureHeight.constant = 0
      }
      
      $0.selectionStyle = .none

      $0.currentAccountAvatar.load(GymRats.currentAccount)
      $0.leaderAvatar.load(challengeInfo.leader)
      
      $0.currentAccountLabel.text = "\(challengeInfo.currentAccountScore)\nMe"
      $0.leaderLabel.text = "\(challengeInfo.leaderScore)\nLeader"

      $0.calendarLabel.text = {
        let daysLeft = challenge.daysLeft.split(separator: " ")
        let first = daysLeft[0]
        let rest = daysLeft[daysLeft.startIndex+1..<daysLeft.endIndex].joined(separator: " ")
        
        return [String(first), rest].joined(separator: "\n")
      }()
    }
  }
}
