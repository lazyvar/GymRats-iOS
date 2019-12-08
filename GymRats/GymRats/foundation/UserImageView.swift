//
//  UserImageView.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import AvatarImageView
import Kingfisher
import SkeletonView

protocol AvatarProtocol {
    var pictureUrl: String? { get }
    var myName: String? { get }
}

@IBDesignable
class UserImageView: UIView {
    
    var avatarInfo: AvatarProtocol?
    var userImage: UIImage?
    
    lazy var imageView: AvatarImageView = {
        let imageView = AvatarImageView(frame: .zero)
        imageView.dataSource = self
        imageView.configuration = AvatarImageConfig()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.backgroundColor = .gray
        
        return imageView
    }()
    
    lazy var skeletonView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.backgroundColor = .clear
        
        return view
    }()
    
    let ringView = RingView(frame: .zero, ringWidth: 0.5, ringColor: UIColor.black.withAlphaComponent(0.1))
    
    var operation: RetrieveImageTask?
    
    func skeletonLoad(avatarInfo: AvatarProtocol) {
        self.avatarInfo = avatarInfo

        guard let proPicUrl = avatarInfo.pictureUrl, let url = URL(string: proPicUrl) else {
            self.userImage = nil
            self.imageView.refresh()

            return
        }

        self.skeletonView.alpha = 1

        operation = KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil) { image, error, _, _ in
            UIView.animate(withDuration: 0.15, animations: {
                self.skeletonView.alpha = 0
            })

            if let image = image {
                self.userImage = image
            } else {
                self.userImage = nil
            }
            self.imageView.refresh()
        }
    }
    
    func load(avatarInfo: AvatarProtocol) {
        self.avatarInfo = avatarInfo
        
        guard let proPicUrl = avatarInfo.pictureUrl, let url = URL(string: proPicUrl) else {
            self.userImage = nil
            self.imageView.refresh()
            
            return
        }
        
        operation = KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil) { image, error, _, _ in
            if let image = image {
                self.userImage = image
            } else {
                self.userImage = nil
            }
            self.imageView.refresh()
        }
    }
    
    func setup() {
        backgroundColor = .clear
        
        addSubview(imageView)
        addSubview(ringView)
        addSubview(skeletonView)

        addConstraintsWithFormat(format: "H:|[v0]|", views: imageView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: imageView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: skeletonView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: skeletonView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(currentUserWasUpdated), name: .updatedCurrentUserPic, object: nil)
    }
    
    @objc func currentUserWasUpdated(notification: Notification) {
        guard let thisUser = avatarInfo as? User else { return }
        guard thisUser.id == GymRatsApp.coordinator.currentUser.id else { return }
        guard let image = notification.object as? UIImage else { return }
        
        self.userImage = image
        self.imageView.refresh()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.layer.cornerRadius = frame.width / 2
        imageView.refresh()
        
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

extension UserImageView: AvatarImageViewDataSource {
    
    var name: String {
        return avatarInfo?.myName ?? ""
    }
    
    var avatar: UIImage? {
        return userImage
    }
}

struct AvatarImageConfig: AvatarImageViewConfiguration {
    let shape: Shape = .circle
}

extension UIView {
    
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
}
