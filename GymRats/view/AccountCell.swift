//
//  AccountCell.swift
//  GymRats
//
//  Created by mack on 4/9/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class AccountCell: UICollectionViewCell {
  @IBOutlet private weak var accountImageView: UserImageView!
  @IBOutlet private weak var accountNameLabel: UILabel! {
    didSet {
      accountNameLabel.textColor = .primaryText
      accountNameLabel.font = .bodyBold
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    accountNameLabel.text = nil
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
  
  static func configure(collectionView: UICollectionView, indexPath: IndexPath, account: Account) -> UICollectionViewCell {
    return collectionView.dequeueReusableCell(withType: AccountCell.self, for: indexPath).apply {
      $0.accountImageView.load(account)
      $0.accountNameLabel.text = account.fullName
    }
  }
}
