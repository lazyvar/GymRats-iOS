//
//  GoatCell.swift
//  GymRats
//
//  Created by Mack on 9/8/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

class GoatCell: UITableViewCell {

    @IBOutlet weak var picture: UIImageView! {
        didSet {
            picture.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet weak var calStack: UIStackView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usersLabel: UILabel!
    @IBOutlet weak var calLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    
    @IBOutlet weak var pictureHeight: NSLayoutConstraint!
    @IBOutlet weak var bg: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bg.backgroundColor = .foreground
        bg.layer.cornerRadius = 4
        bg.clipsToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(enablePress), name: NSNotification.Name(rawValue: "enable_press"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disablePress), name: NSNotification.Name(rawValue: "disable_press"), object: nil)

        shortPress.addTarget(self, action: #selector(handle(shortPress:)))
        shortPress.delegate = self
        addGestureRecognizer(shortPress)

    }
    
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

    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }

}
