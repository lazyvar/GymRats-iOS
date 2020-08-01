//
//  ChallengeBannerImageCell.swift
//  GymRats
//
//  Created by mack on 7/31/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class ChallengeBannerImageCell: UITableViewCell {
  @IBOutlet private weak var bannerImageView: UIImageView! {
    didSet {
      bannerImageView.layer.cornerRadius = 4
      bannerImageView.clipsToBounds = true
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
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
  
  static func configure(tableView: UITableView, indexPath: IndexPath, imageURL: String) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: ChallengeBannerImageCell.self, for: indexPath).apply { cell in
      let skeletonView = UIView()
      skeletonView.isSkeletonable = true
      skeletonView.showAnimatedSkeleton()
      skeletonView.showSkeleton()

      cell.bannerImageView.kf.setImage(with: URL(string: imageURL)!, placeholder: skeletonView, options: [.transition(.fade(0.2))])
    }
  }
}
