//
//  ImageViewController.swift
//  GymRats
//
//  Created by mack on 12/6/20.
//

import UIKit
import Kingfisher

class ImageViewController: UIViewController {
  private let imageView = UIImageView()
  private let medium: Workout.Medium
  
  init(medium: Workout.Medium) {
    self.medium = medium
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    imageView.backgroundColor = .clear
    view.backgroundColor = .clear
    
    imageView.contentMode = .scaleAspectFill
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.clipsToBounds = true
    
    imageView.setupImageViewer(options: [{
      switch UIDevice.contentMode {
      case .light:
        return .theme(.light)
      case .dark:
        return .theme(.dark)
      }
    }()], from: nil)

    view.addSubview(imageView)

    imageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    imageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

    if let url = URL(string: medium.url) {
      imageView.kf.setImage(with: url)
    }
  }
}
