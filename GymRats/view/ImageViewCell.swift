//
//  ImageViewCell.swift
//  GymRats
//
//  Created by mack on 4/9/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class ImageViewCell: UITableViewCell {
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

  private func setImage(_ image: UIImage) {
    let aspectRatio = image.size.width / image.size.height
    let constraint = NSLayoutConstraint(
      item: _imageView!,
      attribute: .width,
      relatedBy: .equal,
      toItem: _imageView!,
      attribute: .height,
      multiplier: aspectRatio,
      constant: 0.0
    )
    
    constraint.priority = .defaultHigh

    aspectRatioConstraint = constraint
    _imageView.image = image
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
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
        cell._imageView.kf.setImage(with: url, options: [.forceTransition, .transition(.custom(duration: 0.2, options: .curveLinear, animations: { imageView, image in
          cell.setImage(image)
          cell.setNeedsLayout()
          cell.layoutIfNeeded()
        }, completion: nil))])
      } else {
        cell._imageView.isHidden = true
      }
    }
  }
}
