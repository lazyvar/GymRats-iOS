//
//  WorkoutImageCell.swift
//  GymRats
//
//  Created by mack on 8/3/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class WorkoutImageCell: UICollectionViewCell {
  @IBOutlet private weak var workoutImageView: UIImageView!
  
  static func configure(collectionView: UICollectionView, indexPath: IndexPath, workoutPhotoURL: String?) -> UICollectionViewCell {
    return collectionView.dequeueReusableCell(withType: WorkoutImageCell.self, for: indexPath).apply { cell in
      if let workoutPhotoURL = workoutPhotoURL, let url = URL(string: workoutPhotoURL) {
        cell.workoutImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
      }
    }
  }
}
