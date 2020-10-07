//
//  LogWorkoutModalViewController.swift
//  GymRats
//
//  Created by mack on 1/5/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import PanModal

class LogWorkoutModalViewController: UIViewController, UINavigationControllerDelegate {
  var showText = true
  
  private let onPickImage: (UIImage) -> Void
  
  @IBOutlet private weak var chooseFromLibraryView: UIView!
  @IBOutlet private weak var takePictureView: UIView!
  @IBOutlet private weak var libraryImageView: UIImageView!
  @IBOutlet private weak var cameraImageView: UIImageView!
  @IBOutlet private weak var textStackView: UIStackView!

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
      self.presentLibrary()
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
      self.takePicture()
      fallthrough
    case .cancelled:
      animateScalePicture(1.0)
    default:
      break
    }
  }

  init(onPickImage: @escaping (UIImage) -> Void) {
    self.onPickImage = onPickImage
      
    super.init(nibName: Self.xibName, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    view.backgroundColor = .background

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
    
    textStackView.isHidden = !showText
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

  private func takePicture() {
    guard UIImagePickerController.isCameraDeviceAvailable(.front) || UIImagePickerController.isCameraDeviceAvailable(.rear) else {
      self.presentAlert(title: "Uh-oh", message: "Your device needs a camera to do that.")
      return
    }

    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = .camera
    imagePicker.delegate = self
    UINavigationBar.appearance().isTranslucent = false
    UINavigationBar.appearance().barTintColor = .background
    UINavigationBar.appearance().tintColor = .primaryText

    self.present(imagePicker, animated: true, completion: nil)
  }
  
  private func presentLibrary() {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = .photoLibrary
    imagePicker.delegate = self
    UINavigationBar.appearance().isTranslucent = false
    UINavigationBar.appearance().barTintColor = .background
    UINavigationBar.appearance().tintColor = .primaryText

    self.present(imagePicker, animated: true, completion: nil)
  }
}

extension LogWorkoutModalViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    return true
  }
}

extension LogWorkoutModalViewController: UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true) {
      self.dismiss(animated: true) {
        if let img = info[.originalImage] as? UIImage {
          self.onPickImage(img)
        }
      }
    }
  }
}

extension LogWorkoutModalViewController: PanModalPresentable {
  var panScrollable: UIScrollView? {
    return nil
  }

  var showDragIndicator: Bool {
    return false
  }
  
  var shortFormHeight: PanModalHeight {
    return showText ? .contentHeight(191) : .contentHeight(135)
  }
}
