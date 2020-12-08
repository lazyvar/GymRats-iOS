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
import RxOptional

protocol CreatedWorkoutDelegate: class {
  func createWorkoutController(created workout: Workout)
}

class CreateWorkoutViewController: UIViewController {
  private let disposeBag = DisposeBag()
  
  weak var delegate: CreatedWorkoutDelegate?
  
  // MARK: Outlets
  
  @IBOutlet weak var scrollView: UIScrollView! {
    didSet {
      scrollView.keyboardDismissMode = .interactive
    }
  }
  
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

  @IBOutlet private weak var healthAppButton: SecondaryButton!
  @IBOutlet private weak var photoOrVideoButton: SecondaryButton!
  @IBOutlet private weak var locationButton: SecondaryButton!
  
  private lazy var nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextTapped))

  // MARK: State

  private var workoutDescription: String?

  private var place: Place? {
    didSet {
      updateViewFromState()
    }
  }

  private var workoutTitle: String? {
    didSet {
      updateViewFromState()
    }
  }
  
  private var healthKitWorkout: HKWorkout? {
    didSet {
      updateViewFromState()
    }
  }

  private var media: [YPMediaItem] = [] {
    didSet {
      updateViewFromState()
    }
  }
  
  // MARK: Services
  
  private let healthService: HealthServiceType = HealthService.shared

  init(healthKitWorkout: HKWorkout) {
    self.healthKitWorkout = healthKitWorkout
    
    super.init(nibName: Self.xibName, bundle: nil)
  }
  
  init(media: [YPMediaItem]) {
    self.media = media
    
    super.init(nibName: Self.xibName, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: View lifecycle
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let healthKitWorkout = healthKitWorkout {
      workoutTitle = healthKitWorkout.workoutActivityType.name
      titleTextField.text = workoutTitle
    }
    
    updateViewFromState()
    setupBackButton()

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
    
    navigationItem.largeTitleDisplayMode = .never
    navigationItem.title = "Log workout"
    navigationItem.rightBarButtonItem = nextButton

    nextButton.tintColor = .brand
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  // MARK: Actions
  
  @objc private func nextTapped() {
    let enterWorkoutDataViewController = EnterWorkoutDataViewController(
      title: workoutTitle ?? "Workout",
      description: workoutDescription,
      media: media,
      healthKitWorkout: healthKitWorkout,
      place: place
    )
    
    enterWorkoutDataViewController.delegate = delegate
  
    push(enterWorkoutDataViewController)
  }
  
  @objc private func titleChanged() {
    workoutTitle = titleTextField.text
  }
  
  @IBAction private func tappedHealthApp(_ sender: Any) {
    presentSourceAlert(source: healthKitWorkout) { [self] in
      healthService.requestWorkoutAuthorization()
        .subscribe(onSuccess: { _ in
          DispatchQueue.main.async {
            let importWorkoutViewController = ImportWorkoutViewController()
            importWorkoutViewController.delegate = self
            
            self.presentForClose(importWorkoutViewController)
          }
        }, onError: { error in
          DispatchQueue.main.async {
            let importWorkoutViewController = ImportWorkoutViewController()
            importWorkoutViewController.delegate = self
            
            self.presentForClose(importWorkoutViewController)
          }
        })
        .disposed(by: disposeBag)
    } clear: { [self] in
      self.healthKitWorkout = nil
    }
  }
  
  @IBAction private func tappedMedia(_ sender: Any) {
    presentSourceAlert(source: media) { [self] in
      let picker = YPImagePicker()
      picker.didFinishPicking { [self] items, cancelled in
        defer { picker.dismiss(animated: true, completion: nil) }
        guard !cancelled else { return }
        
        self.media = items
      }
      
      present(picker, animated: true, completion: nil)
    } clear: { [self] in
      self.media = []
    }
  }
  
  @IBAction private func tappedLocation(_ sender: Any) {
    presentSourceAlert(source: place) { [self] in
      let locationPickerViewController = LocationPickerViewController()
      locationPickerViewController.delegate = self
      
      presentForClose(locationPickerViewController)
    } clear: { [self] in
      self.place = nil
    }
  }
  
  @objc func keyboardWillShow(notification: Notification) {
    let userInfo = notification.userInfo
    let keyboardFrame = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
    let contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardFrame.height, right: 0.0)
    
    scrollView.contentInset = contentInset
    scrollView.scrollIndicatorInsets = contentInset
  }
  
  @objc func keyboardWillHide(notification: Notification) {
    let contentInset = UIEdgeInsets.zero
    
    scrollView.contentInset = contentInset
    scrollView.scrollIndicatorInsets = contentInset
  }
  
  private func presentSourceAlert(source: Any?, present: @escaping () -> Void, clear: @escaping () -> Void) {
    let alertViewController = UIAlertController()
    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    let clear = UIAlertAction(title: "Remove", style: .destructive) { _ in
      clear()
    }
    
    let change = UIAlertAction(title: "Change", style: .default) { _ in
      present()
    }
    
    alertViewController.addAction(change)
    alertViewController.addAction(clear)
    alertViewController.addAction(cancel)
    
    if source == nil || (source as? Occupiable)?.isEmpty == true {
      present()
    } else {
      self.present(alertViewController, animated: true, completion: nil)
    }
  }
  
  private func updateViewFromState() {
    guard isViewLoaded else { return }
    
    let hasTitle =  (workoutTitle ?? "").isNotEmpty
    let hasHealthAppWorkout = healthKitWorkout != nil
    let hasMedia = media.isNotEmpty
    let hasLocation = place != nil
  
    nextButton.isEnabled = hasTitle && (hasHealthAppWorkout || hasMedia)
    healthAppCheckbox.image = hasHealthAppWorkout ? .checked : .notChecked
    mediaCheckbox.image = hasMedia ? .checked : .notChecked
    locationCheckbox.image = hasLocation ? .checked : .notChecked
    healthAppCheckbox.tintColor = hasHealthAppWorkout ? .goodGreen : .secondaryText
    mediaCheckbox.tintColor = hasMedia ? .goodGreen : .secondaryText
    locationCheckbox.tintColor = hasLocation ? .goodGreen : .secondaryText
    
    if hasHealthAppWorkout && !hasMedia {
      sourceDetailsLabel.text = "Verified using the Health app. Optionally add a photo or video."
    } else if !hasHealthAppWorkout && hasMedia {
      sourceDetailsLabel.text = "Verified using a photo or video. Optionally import a workout from the Health app."
    } else if hasHealthAppWorkout && hasMedia && !hasLocation {
      sourceDetailsLabel.text = "Verified using the Health app and photo or video. Optionally tag a location."
    } else if hasHealthAppWorkout && hasMedia && hasLocation {
      sourceDetailsLabel.text = "Fully verified."
    } else {
      sourceDetailsLabel.text = "Either a workout imported from the Health app or a photo or video is required."
    }
    
    if let healthKitWorkout = healthKitWorkout {
      let duration = Int(healthKitWorkout.duration / 60)
      
      healthAppButton.setTitle("\(healthKitWorkout.workoutActivityType.name) - \(duration) minutes", for: .normal)
    } else {
      healthAppButton.setTitle("Health app", for: .normal)
    }
    
    if let place = place {
      locationButton.setTitle("\(place.name)", for: .normal)
    } else {
      locationButton.setTitle("Location", for: .normal)
    }
    
    if media.isEmpty {
      photoOrVideoButton.setTitle("Photo or video", for: .normal)
    } else {
      let photos = media.filter { item -> Bool in
        switch item {
        case .photo: return true
        case .video: return false
        }
      }
      
      let videos = media.filter { item -> Bool in
        switch item {
        case .photo: return false
        case .video: return true
        }
      }
      
      let p = photos.isNotEmpty ? "\(photos.count) photo\(photos.count == 1 ? "" : "s")" : nil
      let v = videos.isNotEmpty ? "\(videos.count) video\(videos.count == 1 ? "" : "s")" : nil
      let content = [p, v].compactMap { $0 }.joined(separator: ", ")
      
      photoOrVideoButton.setTitle(content, for: .normal)
    }
  }
}

extension CreateWorkoutViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    workoutDescription = descTextView.text ?? ""
  }
}

extension CreateWorkoutViewController: LocationPickerViewControllerDelegate {
  func didPickLocation(_ locationPickerViewController: LocationPickerViewController, place: Place) {
    self.place = place
    locationPickerViewController.dismiss(animated: true)
  }
}

extension CreateWorkoutViewController: ImportWorkoutViewControllerDelegate {
  func importWorkoutViewController(_ importWorkoutViewController: ImportWorkoutViewController, imported workout: HKWorkout) {
    self.healthKitWorkout = workout
    
    importWorkoutViewController.dismiss(animated: true, completion: nil)
  }
}
