//
//  CreateWorkoutViewController.swift
//  GymRats
//
//  Created by Mack Hasz on 2/6/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import HealthKit
import GooglePlaces
import HealthKit
import RSKPlaceholderTextView
import YPImagePicker

protocol CreatedWorkoutDelegate: class {
  func createWorkoutController(_ createWorkoutController: CreateWorkoutViewController, created workout: Workout)
}

class CreateWorkoutViewController: UIViewController {
  
  // MARK: Outlets
  
  @IBOutlet private weak var titleTextField: UITextField! {
    didSet {
      titleTextField.font = .body
      titleTextField.addTarget(self, action: #selector(titleChanged), for: .editingChanged)
    }
  }
  
  @IBOutlet private weak var descTextView: RSKPlaceholderTextView! {
    didSet {
      descTextView.delegate = self
      descTextView.placeholder = "Description (optional)"
      descTextView.font = .body
      descTextView.tintColor = .none
      descTextView.backgroundColor = .clear
      descTextView.contentInset = .init(top: 8, left: 0, bottom: 0, right: 0)
      descTextView.textContainerInset = .init(top: 8, left: 0, bottom: 0, right: 0)
      descTextView.textContainer.lineFragmentPadding = 0
    }
  }
  
  @IBOutlet weak var contentStackView: UIStackView! {
    didSet {
      contentStackView.layer.cornerRadius = 8
      contentStackView.clipsToBounds = true
      contentStackView.backgroundColor = .foreground
    }
  }
  
  @IBOutlet private weak var sourcesLabel: UILabel! {
    didSet {
      sourcesLabel.textColor = .primaryText
      sourcesLabel.font = .body
    }
  }
  
  @IBOutlet private weak var sourceDetailsLabel: UILabel! {
    didSet {
      sourceDetailsLabel.textColor = .secondaryText
      sourceDetailsLabel.font = .body
    }
  }
  
  @IBOutlet private weak var lineView: UIView!
  
  @IBOutlet private weak var healthAppCheckbox: UIImageView! {
    didSet {
      healthAppCheckbox.tintColor = .secondaryText
    }
  }

  @IBOutlet private weak var mediaCheckbox: UIImageView! {
    didSet {
      mediaCheckbox.tintColor = .secondaryText
    }
  }
  
  @IBOutlet private weak var locationCheckbox: UIImageView! {
    didSet {
      locationCheckbox.tintColor = .secondaryText
    }
  }

  // MARK: State

  private var workoutTitle: String?
  private var workoutDescription: String?
  private var place: Place?
  private var healthKitWorkout: HKWorkout?
  private var media: [YPMediaItem] = []

  // MARK: View lifecycle
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if #available(iOS 13.0, *) {
      if traitCollection.userInterfaceStyle == .dark {
          descTextView.placeholderColor = .init(red: 0.92, green: 0.92, blue: 0.96, alpha: 0.3)
          lineView.backgroundColor = .init(red: 0.92, green: 0.92, blue: 0.96, alpha: 0.3)
      } else {
          descTextView.placeholderColor = .init(red: 0, green: 0.1, blue: 0.098, alpha: 0.22)
      }
    } else {
      descTextView.placeholderColor = .init(red: 0, green: 0, blue: 0.098, alpha: 0.22)
    }
    
    view.backgroundColor = .background

    let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextTapped))
    nextButton.tintColor = .brand
    
    navigationItem.largeTitleDisplayMode = .never
    navigationItem.title = "Log workout"
    navigationItem.rightBarButtonItem = nextButton
  }
  
  // MARK: Actions
  
  @objc private func nextTapped() {
    // ...
  }
  
  @objc private func titleChanged() {
    workoutTitle = titleTextField.text
  }
  
  @IBAction private func tappedHealthApp(_ sender: Any) {
    
  }
  
  @IBAction private func tappedMedia(_ sender: Any) {
    
  }
  
  @IBAction private func tappedLocation(_ sender: Any) {
    
  }
}

extension CreateWorkoutViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    workoutDescription = descTextView.text ?? ""
  }
}

extension CreateWorkoutViewController: ImportWorkoutViewControllerDelegate {
  func importWorkoutViewController(_ importWorkoutViewController: ImportWorkoutViewController, imported workout: HKWorkout) {
    
  }
}

extension CreateWorkoutViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .authorizedWhenInUse, .authorizedAlways:
//      getPlacesForCurrentLocation()
    break
    case .denied, .restricted:
      hideLoadingBar()
      presentAlert(title: "Location Permission Required", message: "To check in a location, please enable the permission in settings.")
    case .notDetermined:
      break
    @unknown default:
      break
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    // mt
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    presentAlert(title: "Error Getting Location", message: "Please try again.")
  }
}

//extension CreateWorkoutViewController: UITextFieldDelegate {
//  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//    return false
//  }
//}

extension Double {
  /// Rounds the double to decimal places value
  func rounded(places: Int) -> Double {
    let divisor = pow(10.0, Double(places))
  
    return (self * divisor).rounded() / divisor
  }
}
