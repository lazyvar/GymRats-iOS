//
//  LogWorkoutListCell.swift
//  GymRats
//
//  Created by mack on 1/5/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class LogWorkoutListCell: UITableViewCell {

    @IBOutlet weak var chooseFromLibraryView: UIView!
    @IBOutlet weak var takePictureView: UIView!
    
    @IBOutlet weak var libraryImageView: UIImageView!
    @IBOutlet weak var cameraImageView: UIImageView!
    
    @IBOutlet weak var textStackView: UIStackView!
    
    var onChooseFromLibrary: (() -> Void)?
    var onTakePicture: (() -> Void)?
    
    let shortPressLibrary: UILongPressGestureRecognizer = {
        let press = UILongPressGestureRecognizer()
        press.minimumPressDuration = 0.05
        press.cancelsTouchesInView = false
        
        return press
    }()
    
    let shortPressPicture: UILongPressGestureRecognizer = {
        let press = UILongPressGestureRecognizer()
        press.minimumPressDuration = 0.05
        press.cancelsTouchesInView = false
        
        return press
    }()

    @objc func handleLibrary(shortPress: UILongPressGestureRecognizer) {
        switch shortPress.state {
        case .began:
            animateScaleLibrary(0.925)
        case .ended, .failed:
            self.onChooseFromLibrary?()
            fallthrough
        case .cancelled:
            animateScaleLibrary(1.0)
        default:
            break
        }
    }

    @objc func handlePicture(shortPress: UILongPressGestureRecognizer) {
        switch shortPress.state {
        case .began:
            animateScalePicture(0.925)
        case .ended, .failed:
            self.onTakePicture?()
            fallthrough
        case .cancelled:
            animateScalePicture(1.0)
        default:
            break
        }
    }

    override func awakeFromNib() {
        shortPressLibrary.addTarget(self, action: #selector(handleLibrary(shortPress:)))
        shortPressLibrary.delegate = self
        shortPressPicture.addTarget(self, action: #selector(handlePicture(shortPress:)))
        shortPressPicture.delegate = self

        chooseFromLibraryView.layer.cornerRadius = 4
        takePictureView.layer.cornerRadius = 4
        
        chooseFromLibraryView.backgroundColor = .foreground
        takePictureView.backgroundColor = .foreground
        
        chooseFromLibraryView.addGestureRecognizer(shortPressLibrary)
        takePictureView.addGestureRecognizer(shortPressPicture)
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }

    func animateScaleLibrary(_ scale: CGFloat, onCompletion: (() -> Void)? = nil) {
      UIView.animate(withDuration: 0.15, delay: 0, options: .curveLinear, animations: {
        self.chooseFromLibraryView.transform = CGAffineTransform(scaleX: scale, y: scale)
      }, completion: { _ in
          onCompletion?()
      })
    }

    func animateScalePicture(_ scale: CGFloat, onCompletion: (() -> Void)? = nil) {
      UIView.animate(withDuration: 0.15, delay: 0, options: .curveLinear, animations: {
        self.takePictureView.transform = CGAffineTransform(scaleX: scale, y: scale)
      }, completion: { _ in
          onCompletion?()
      })
    }

}
