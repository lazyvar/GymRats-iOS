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

@IBDesignable
class UserImageView: UIView {
    
    var user: User?
    var userImage: UIImage?
    
    lazy var imageView: AvatarImageView = {
        let imageView = AvatarImageView(frame: .zero)
        imageView.dataSource = self
        imageView.configuration = AvatarImageConfig()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    let ringView = RingView(frame: .zero, ringWidth: 0.5, ringColor: UIColor.black.withAlphaComponent(0.1))
    
    func load(user: User) {
        self.user = user
        
        guard let proPicUrl = user.proPicUrl, let url = URL(string: proPicUrl) else {
            self.userImage = nil
            self.imageView.refresh()
            
            return
        }
        
        KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil) { image, error, _, _ in
            if let image = image {
                self.userImage = image
            } else {
                self.userImage = nil
            }
            self.imageView.refresh()
        }
    }
    
    func setup() {
        addSubview(imageView)
        addSubview(ringView)
        
        addConstraintsWithFormat(format: "H:|[v0]|", views: imageView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.layer.cornerRadius = frame.width / 2
        imageView.refresh()
        
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
        return user?.fullName ?? ""
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




