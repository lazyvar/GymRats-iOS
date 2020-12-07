//
//  MediaTableViewCell.swift
//  GymRats
//
//  Created by mack on 12/6/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class MediaTableViewCell: UITableViewCell {
  @IBOutlet private weak var mediaView: UIView!
    
  private var mediaViewController: MediaPageViewController?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    separatorInset = .init(top: .zero, left: .zero, bottom: .zero, right: .greatestFiniteMagnitude)
    clipsToBounds = true
    layer.cornerRadius = 4
    layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
  }
  
  func cleanUp() {
    mediaViewController?.removeFromParent()
    mediaViewController?.view.removeFromSuperview()
    mediaViewController = nil
  }
  
  static func configure(tableView: UITableView, indexPath: IndexPath, media: [Workout.Medium], parent: UIViewController) -> MediaTableViewCell {
    return tableView.dequeueReusableCell(withType: MediaTableViewCell.self, for: indexPath).apply { cell in
      let mediaViewController = MediaPageViewController(media: media)
      mediaViewController.view.inflate(in: cell.mediaView)
      
      parent.addChild(mediaViewController)
      mediaViewController.didMove(toParent: parent)
      
      cell.mediaViewController = mediaViewController
    }
  }
}
