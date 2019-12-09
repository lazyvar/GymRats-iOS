//
//  TwerkoutCell.swift
//  GymRats
//
//  Created by Mack on 9/8/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

class TwerkoutCell: UITableViewCell {
    
    @IBOutlet weak var twerk: UIImageView!
    @IBOutlet weak var det: UILabel!
    @IBOutlet weak var tit: UILabel!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var bg: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var userImage: UserImageView!
    
    @IBOutlet weak var desc: UILabel!
    
    var pressBlock: (() -> Void)?
    
    let shortPress: UILongPressGestureRecognizer = {
        let press = UILongPressGestureRecognizer()
        press.minimumPressDuration = 0.05
        press.cancelsTouchesInView = false
        
        return press
    }()

    @objc func handle(shortPress: UILongPressGestureRecognizer) {
        switch shortPress.state {
        case .began:
            animateScale(0.95)
        case .ended, .failed:
            self.pressBlock?()
            fallthrough
        case .cancelled:
            animateScale(1.0)
        default:
            break
        }
    }
    
    @objc func enablePress() {
        shortPress.isEnabled = true
    }
    
    @objc func disablePress() {
        shortPress.isEnabled = false
    }
    
    func animateScale(_ scale: CGFloat, onCompletion: (() -> Void)? = nil) {
      UIView.animate(withDuration: 0.15, delay: 0, options: .curveLinear, animations: {
          self.transform = CGAffineTransform(scaleX: scale, y: scale)
      }, completion: { _ in
          onCompletion?()
      })
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        shortPress.addTarget(self, action: #selector(handle(shortPress:)))
        shortPress.delegate = self
        addGestureRecognizer(shortPress)
        
        NotificationCenter.default.addObserver(self, selector: #selector(enablePress), name: NSNotification.Name(rawValue: "enable_press"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disablePress), name: NSNotification.Name(rawValue: "disable_press"), object: nil)
        
//        desc.font = .body
//        tit.font = .bodyBold
//        det.font = .body
//        timeLabel.font = .details
        bg.backgroundColor = .foreground
        bg.layer.cornerRadius = 4

//        shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
//        shadowView.layer.shadowRadius = 10
//        shadowView.layer.shadowColor = UIColor.shadow.cgColor
//        shadowView.layer.shadowOpacity = 0.5

        
        
        shadowView.layer.cornerRadius = 4
        shadowView.clipsToBounds = true
        shadowView.isSkeletonable = true
        shadowView.startSkeletonAnimation()
        shadowView.showSkeleton()
        
        twerk.contentMode = .scaleAspectFill
        twerk.layer.cornerRadius = 4
        twerk.clipsToBounds = true
        clipsToBounds = false
    }
      
      override func prepareForReuse() {
        super.prepareForReuse()
        
        pressBlock = nil
        twerk.image = nil
        twerk.kf.cancelDownloadTask()
        shadowView.startSkeletonAnimation()
        shadowView.showSkeleton()
    }

}

extension TwerkoutCell {
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
    
}
