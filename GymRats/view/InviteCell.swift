//
//  InviteCell.swift
//  GymRats
//
//  Created by mack on 4/9/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class InviteCell: UICollectionViewCell {
  @IBOutlet private weak var plusImageView: UIImageView! {
    didSet {
      plusImageView.tintColor = .white
    }
  }
  
  @IBOutlet private weak var inviteLabel: UILabel! {
    didSet {
      inviteLabel.textColor = .primaryText
      inviteLabel.font = .bodyBold
      inviteLabel.text = "Invite"
    }
  }
  
  @IBOutlet weak var bgView: UIView! {
    didSet {
      bgView.backgroundColor = .brand
      bgView.clipsToBounds = true
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    addObserver(self, forKeyPath: "bgView.bounds", options: .new, context: nil)
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "bgView.bounds" {
      bgView.layer.cornerRadius = bgView.bounds.size.width / 2
    } else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
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

  static func configure(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
    return collectionView.dequeueReusableCell(withType: InviteCell.self, for: indexPath)
  }
}
