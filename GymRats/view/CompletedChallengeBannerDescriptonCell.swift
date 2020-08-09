//
//  CompletedChallengeBannerDescriptonCell.swift
//  GymRats
//
//  Created by mack on 8/8/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class CompletedChallengeBannerDescriptonCell: UITableViewCell {
  @IBOutlet private weak var label: UILabel! {
    didSet {
      label.font = .body
      label.textColor = .primaryText
    }
  }
  
  @IBOutlet private weak var complete: UILabel! {
    didSet {
      complete.font = .h4Bold
      complete.textColor = .primaryText
    }
  }
  
  @IBOutlet private weak var bannerImageView: UIImageView! {
    didSet {
      bannerImageView.contentMode = .scaleAspectFill
      bannerImageView.clipsToBounds = true
      bannerImageView.round(corners: [.topLeft, .topRight], radius: 4)
    }
  }
  
  static func configure(tableView: UITableView, indexPath: IndexPath, banner: String, description: NSAttributedString) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: CompletedChallengeBannerDescriptonCell.self, for: indexPath).apply {
      $0.label.attributedText = description
      
      if let url = URL(string: banner){
        $0.bannerImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
      }
    }
  }
}
