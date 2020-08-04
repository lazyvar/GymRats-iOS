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
  
  static func configure(collectionView: UICollectionView, indexPath: IndexPath, workoutImage: UIImage?) -> UICollectionViewCell {
    return collectionView.dequeueReusableCell(withType: WorkoutImageCell.self, for: indexPath).apply { cell in
      cell.workoutImageView.image = workoutImage
    }
  }
}
