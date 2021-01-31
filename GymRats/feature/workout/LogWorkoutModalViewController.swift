//
//  LogWorkoutModalViewController.swift
//  GymRats
//
//  Created by mack on 1/5/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import PanModal
import HealthKit
import RxSwift
import YPImagePicker
import PanModal

protocol LogWorkoutModalViewControllerDelegate: class {
  func didImportSteps(_ navigationController: UINavigationController, steps: StepCount)
  func didImportWorkout(_ navigationController: UINavigationController, workout: HKWorkout)
  func didPickMedia(_ picker: YPImagePicker, media: [YPMediaItem])
}

class LogWorkoutModalViewController: UIViewController, UINavigationControllerDelegate {
  private let disposeBag = DisposeBag()
  private let healthService: HealthServiceType = HealthService.shared

  @IBOutlet private weak var chooseFromLibraryView: UIView!
  @IBOutlet private weak var takePictureView: UIView!
  @IBOutlet private weak var appleHealthView: UIView!
  @IBOutlet private weak var libraryImageView: UIImageView!
  @IBOutlet private weak var cameraImageView: UIImageView!
  @IBOutlet private weak var heartImageView: UIImageView!

  @IBOutlet private weak var healthLabel: UILabel! {
    didSet {
      healthLabel.textColor = .primaryText
    }
  }
  
  @IBOutlet private weak var cameraLabel: UILabel! {
    didSet {
      cameraLabel.textColor = .primaryText
    }
  }
  
  @IBOutlet private weak var libraryLabel: UILabel! {
    didSet {
      libraryLabel.textColor = .primaryText
    }
  }
  
  weak var delegate: LogWorkoutModalViewControllerDelegate?
  
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

  let shortPressAppleHealth: UILongPressGestureRecognizer = {
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
      self.chooseFromLibrary()
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
      self.takePhotoOrVideo()
      fallthrough
    case .cancelled:
      animateScalePicture(1.0)
    default:
      break
    }
  }

  @objc func handleAppleHealth(shortPress: UILongPressGestureRecognizer) {
    switch shortPress.state {
    case .began:
      animateScaleHeart(0.925)
    case .ended, .failed:
      self.healthAppTapped()
      fallthrough
    case .cancelled:
      animateScaleHeart(1.0)
    default:
      break
    }
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

  func animateScaleHeart(_ scale: CGFloat, onCompletion: (() -> Void)? = nil) {
    UIView.animate(withDuration: 0.15, delay: 0, options: .curveLinear, animations: {
      self.appleHealthView.transform = CGAffineTransform(scaleX: scale, y: scale)
    }, completion: { _ in
      onCompletion?()
    })
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    shortPressLibrary.addTarget(self, action: #selector(handleLibrary(shortPress:)))
    shortPressLibrary.delegate = self
    shortPressPicture.addTarget(self, action: #selector(handlePicture(shortPress:)))
    shortPressPicture.delegate = self
    shortPressAppleHealth.addTarget(self, action: #selector(handleAppleHealth(shortPress:)))
    shortPressAppleHealth.delegate = self
    
    chooseFromLibraryView.layer.cornerRadius = 8
    takePictureView.layer.cornerRadius = 8
    appleHealthView.layer.cornerRadius = 8
    
    chooseFromLibraryView.backgroundColor = .foreground
    takePictureView.backgroundColor = .foreground
    appleHealthView.backgroundColor = .foreground
    
    chooseFromLibraryView.addGestureRecognizer(shortPressLibrary)
    takePictureView.addGestureRecognizer(shortPressPicture)
    appleHealthView.addGestureRecognizer(shortPressAppleHealth)
    
    cameraImageView.tintColor = .primaryText
    libraryImageView.tintColor = .primaryText
    heartImageView.tintColor = .primaryText

    view.backgroundColor = .background
  }
  
  @objc private func healthAppTapped() {
//    defer { healthService.markPromptSeen() }
    
//    if healthService.didShowGymRatsPrompt {
      presentImportWorkout()
//    } else {
//      let healthAppViewController = HealthAppViewController()
//      healthAppViewController.delegate = self
//      healthAppViewController.title = "Sync with Health app?"
//
//      presentInNav(healthAppViewController)
//    }
  }

  private func presentImportWorkout() {
    healthService.requestWorkoutAuthorization()
      .subscribe(onSuccess: { _ in
        DispatchQueue.main.async {
          let importWorkoutViewController = ImportWorkoutViewController()
          importWorkoutViewController.delegate = self
          
          self.presentInNav(importWorkoutViewController)
        }
      }, onError: { error in
        DispatchQueue.main.async {
          let importWorkoutViewController = ImportWorkoutViewController()
          importWorkoutViewController.delegate = self
          
          self.presentInNav(importWorkoutViewController)
        }
      })
      .disposed(by: disposeBag)
  }

  @objc private func takePhotoOrVideo() {
    var config = YPImagePickerConfiguration.shared
    config.startOnScreen = .photo

    let picker = YPImagePicker(configuration: config)
    picker.modalPresentationStyle = .popover
    picker.navigationBar.backgroundColor = .background
    picker.navigationBar.tintColor = .primaryText
    picker.navigationBar.barTintColor = .background
    picker.navigationBar.isTranslucent = false
    picker.navigationBar.shadowImage = UIImage()
    
    DispatchQueue.main.async {
      picker.viewControllers.first?.setupBackButton()
      picker.viewControllers.first?.navigationItem.leftBarButtonItem = .close(target: picker)
    }
    
    picker.didFinishPicking { [self] items, cancelled in
      didFinishPicking(picker: picker, items: items, cancelled: cancelled)
    }

    present(picker, animated: true, completion: nil)
  }

  @objc private func chooseFromLibrary() {
    var config = YPImagePickerConfiguration.shared
    config.startOnScreen = .library

    let picker = YPImagePicker(configuration: config)
    picker.modalPresentationStyle = .popover
    picker.navigationBar.backgroundColor = .background
    picker.navigationBar.tintColor = .primaryText
    picker.navigationBar.barTintColor = .background
    picker.navigationBar.isTranslucent = false
    picker.navigationBar.shadowImage = UIImage()

    DispatchQueue.main.async {
      picker.viewControllers.first?.setupBackButton()
      picker.viewControllers.first?.navigationItem.leftBarButtonItem = .close(target: picker)
    }

    picker.didFinishPicking { [self] items, cancelled in
      didFinishPicking(picker: picker, items: items, cancelled: cancelled)
    }
    
    present(picker, animated: true, completion: nil)
  }
  
  private func didFinishPicking(picker: YPImagePicker, items: [YPMediaItem], cancelled: Bool) {
    if cancelled {
      picker.dismiss(animated: true, completion: nil)
      
      return
    }

    func complete() {
      self.delegate?.didPickMedia(picker, media: items)
    }
    
    if items.singleFromCamera {
      let preview = MediaItemPreviewViewController(items: items)
      preview.onAcceptance = { _ in
        complete()
      }
      
      picker.pushViewController(preview, animated: false)
    } else {
      complete()
    }
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

extension LogWorkoutModalViewController: HealthAppViewControllerDelegate {
  func closed(_ healthAppViewController: HealthAppViewController, tappedAllow: Bool) {
    healthAppViewController.dismiss(animated: true) { [self] in
      if tappedAllow {
        presentImportWorkout()
      }
    }
  }

  func closeButtonHidden() -> Bool {
    return false
  }
}

extension LogWorkoutModalViewController: ImportWorkoutViewControllerDelegate {
  func importWorkoutViewController(_ importWorkoutViewController: ImportWorkoutViewController, importedSteps steps: StepCount) {
    delegate?.didImportSteps(importWorkoutViewController.navigationController!, steps: steps)
  }

  func importWorkoutViewController(_ importWorkoutViewController: ImportWorkoutViewController, imported workout: HKWorkout) {
    delegate?.didImportWorkout(importWorkoutViewController.navigationController!, workout: workout)
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
    return .contentHeight(191)
  }
  
  var longFormHeight: PanModalHeight {
    return .contentHeight(191)
  }
  
  var shouldRoundTopCorners: Bool {
    return true
  }
}

extension Array where Element == YPMediaItem {
  var singleFromCamera: Bool {
    guard count == 1 else { return false }
    
    return
      singleVideo?.fromCamera
      ?? singlePhoto?.fromCamera
      ?? false
  }
}
