//
//  ImageViewCell.swift
//  GymRats
//
//  Created by mack on 4/9/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import Kingfisher

class ImageViewCell: UITableViewCell {
  @IBOutlet private weak var skeletonView: UIView! {
    didSet {
      skeletonView.isSkeletonable = true
      skeletonView.showAnimatedSkeleton()
    }
  }
  
  @IBOutlet private weak var _imageView: UIImageView! {
    didSet {
      _imageView.contentMode = .scaleAspectFill
    }
  }
  
  private var aspectRatioConstraint: NSLayoutConstraint? {
    didSet {
      if oldValue != nil {
        _imageView.removeConstraint(oldValue!)
      }
      
      if aspectRatioConstraint != nil {
        _imageView.addConstraint(aspectRatioConstraint!)
      }
    }
  }

  private func setAspectRatio(_ aspectRatio: CGFloat) {
    let constraint = NSLayoutConstraint(
      item: _imageView!,
      attribute: .height,
      relatedBy: .equal,
      toItem: _imageView!,
      attribute: .width,
      multiplier: aspectRatio,
      constant: 0.0
    )
    
    constraint.priority = .defaultHigh

    aspectRatioConstraint = constraint
  }
  
  private func setImage(_ image: UIImage) {
    setAspectRatio(image.size.height / image.size.width)
    _imageView.image = image
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    _imageView.alpha = 1
    setAspectRatio(1)
    
    separatorInset = .init(top: .zero, left: .zero, bottom: .zero, right: .greatestFiniteMagnitude)
    clipsToBounds = true
    layer.cornerRadius = 4
    layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
  
    _imageView.isHidden = false
  }
  
  static func configure(tableView: UITableView, indexPath: IndexPath, imageURL: String) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: ImageViewCell.self, for: indexPath).apply { cell in
      if let url = URL(string: imageURL) {
        if let image = KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: imageURL) ?? KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: imageURL) {
          cell.setImage(image)
        } else {
          cell._imageView.alpha = 0
          cell._imageView.kf.setImage(with: url, options: [.forceRefresh]) { image, _, _, _ in
            guard let image = image else { return }
            
            UIView.performWithoutAnimation {
              cell.setImage(image)
            }
            
            UIView.animate(withDuration: 0.15) {
              cell.setNeedsLayout()
              cell.layoutIfNeeded()
              tableView.beginUpdates()
              tableView.endUpdates()
            }
            
            UIView.animate(withDuration: 0.1, delay: 0.15, options: .curveLinear, animations: {
              cell._imageView.alpha = 1
            }, completion:  nil)
          }
        }
      } else {
        cell._imageView.isHidden = true
      }
    }
  }
}
