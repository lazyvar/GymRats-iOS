//
//  UserImageView.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import Kingfisher
import SkeletonView
import LetterAvatarKit

protocol Avatar {
  var avatarName: String? { get }
  var avatarImageURL: String? { get }
}

@IBDesignable class UserImageView: UIView {
  private var avatar: Any?
  private let ringView = RingView(frame: .zero, ringWidth: 0.5, ringColor: .clear)

  private lazy var imageView: UIImageView = {
    let imageView = UIImageView(frame: .zero)
    imageView.contentMode = .scaleAspectFill
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.clipsToBounds = true
    imageView.backgroundColor = .clear
    
    return imageView
  }()
    
  private lazy var skeletonView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.clipsToBounds = true
    view.backgroundColor = .clear
      
    return view
  }()
  
  func clear() {
    imageView.image = nil
    imageView.kf.cancelDownloadTask()
  }
  
  func load(_ avatar: Avatar) {
    if let url = avatar.avatarImageURL, let resource = URL(string: url) {
      imageView.kf.setImage(with: resource, options: [.transition(.fade(0.2))])
    } else if let name = avatar.avatarName {
      imageView.image = LetterAvatarMaker()
        .setUsername(name.uppercased())
        .setLettersFont(.h1)
        .build()
    } else {
      imageView.image = UIImage(color: .clear)
    }
  }
  
  private func setup() {
    backgroundColor = .clear
      
    addSubview(imageView)
    addSubview(ringView)
    addSubview(skeletonView)

    imageView.fill(in: self)
    skeletonView.fill(in: self)
    
    NotificationCenter.default.addObserver(self, selector: #selector(currentAccountUpdated), name: .currentAccountUpdated, object: nil)
  }
    
  @objc private func currentAccountUpdated(notification: Notification) {
    guard let thisUser = avatar as? Account else { return }
    guard thisUser.id == GymRats.currentAccount.id else { return }
    guard let account = notification.object as? Account else { return }
    
    load(account)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    
    imageView.layer.cornerRadius = frame.width / 2
    
    skeletonView.layer.cornerRadius = frame.width / 2
    skeletonView.showAnimatedSkeleton()

    let scale: CGFloat = 1.16
    let newWidth = frame.width * scale
    let newHeight = frame.height * scale
    
    let diffY = newWidth - frame.width
    let diffX = newHeight - frame.height
    
    ringView.frame = CGRect(x: -diffX/2, y: -diffY/2, width: newWidth, height: newHeight)
  }
    
  override init(frame: CGRect = .zero) {
    super.init(frame: frame)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    setup()
  }
}
