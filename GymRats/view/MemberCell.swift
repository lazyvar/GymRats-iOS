//
//  MemberCell.swift
//  GymRats
//
//  Created by mack on 8/4/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class MemberCell: UICollectionViewCell {
  @IBOutlet private weak var avatarView: UserImageView!

  override func prepareForReuse() {
    super.prepareForReuse()
    
    avatarView.clear()
  }
  
  static func configure(collectionView: UICollectionView, indexPath: IndexPath, account: Account) -> UICollectionViewCell {
    return collectionView.dequeueReusableCell(withType: MemberCell.self, for: indexPath).apply { cell in
      cell.avatarView.load(account)
    }
  }
}
