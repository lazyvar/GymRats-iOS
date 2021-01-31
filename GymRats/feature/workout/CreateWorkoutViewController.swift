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
  
  @IBOutlet private weak var previewImageView: UIImageView! {
    didSet {
      previewImageView.layer.cornerRadius = 4
      previewImageView.clipsToBounds = true
      previewImageView.contentMode = .scaleAspectFill
    }
  }
  
  @IBOutlet private weak var stackView: UIStackView!
  
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
      sourcesLabel.font = .emphasis
    }
  }
  
  @IBOutlet private weak var sourceDetailsLabel: UILabel! {
    didSet {
      sourceDetailsLabel.textColor = .primaryText
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
  
  private var healthAppSource: HealthAppSource? {
    didSet {
      updateViewFromState()
    }
  }

  private var media: [YPMediaItem] = [] {
    didSet {
      updateViewFromState()
    }
  }
  
  init(healthAppSource: HealthAppSource) {
    self.healthAppSource = healthAppSource
    
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
        
    let i1 = UIImageView(image: .chevronRight)
    let i2 = UIImageView(image: .chevronRight)
    let i3 = UIImageView(image: .chevronRight)

    i1.translatesAutoresizingMaskIntoConstraints = false
    i2.translatesAutoresizingMaskIntoConstraints = false
    i3.translatesAutoresizingMaskIntoConstraints = false

    i1.tintColor = .secondaryText
    i2.tintColor = .secondaryText
    i3.tintColor = .secondaryText

    healthAppButton.addSubview(i1)
    photoOrVideoButton.addSubview(i2)
    locationButton.addSubview(i3)

    i1.trailingAnchor.constraint(equalTo: healthAppButton.trailingAnchor, constant: -5).isActive = true
    i2.trailingAnchor.constraint(equalTo: photoOrVideoButton.trailingAnchor, constant: -5).isActive = true
    i3.trailingAnchor.constraint(equalTo: locationButton.trailingAnchor, constant: -5).isActive  = true

    i1.centerYAnchor.constraint(equalTo: healthAppButton.centerYAnchor).isActive = true
    i2.centerYAnchor.constraint(equalTo: photoOrVideoButton.centerYAnchor).isActive = true
    i3.centerYAnchor.constraint(equalTo: locationButton.centerYAnchor).isActive = true

    i1.constrainWidth(25)
    i1.constrainHeight(25)
    i2.constrainWidth(25)
    i2.constrainHeight(25)
    i3.constrainWidth(25)
    i3.constrainHeight(25)
  
    view.rx.panGesture()
      .subscribe(onNext: { [self] gesture in
        switch gesture.state {
        case .began:
          view.endEditing(true)
        default: break
        }
      })
      .disposed(by: disposeBag)

    view.rx.tapGesture()
      .subscribe(onNext: { [self] _ in
        view.endEditing(true)
      })
      .disposed(by: disposeBag)
    
//    mediaCheckbox.rx.tapGesture()
//      .subscribe(onNext: { [self] gesture in
//        if gesture.state == .ended {
//          tappedMedia(self)
//        }
//      })
//      .disposed(by: disposeBag)
//
//    locationCheckbox.rx.tapGesture()
//      .subscribe(onNext: { [self] gesture in
//        if gesture.state == .ended {
//          tappedLocation(self)
//        }
//      })
//      .disposed(by: disposeBag)
//
//    healthAppCheckbox.rx.tapGesture()
//      .subscribe(onNext: { [self] gesture in
//        if gesture.state == .ended {
//          tappedHealthApp(self)
//        }
//      })
//      .disposed(by: disposeBag)
//
//    previewImageView.rx.tapGesture()
//      .subscribe(onNext: { [self] gesture in
//        if gesture.state == .ended {
//          tappedMedia(self)
//        }
//      })
//      .disposed(by: disposeBag)
    
    if let healthAppSource = healthAppSource {
      switch healthAppSource {
      case .left(let healthKitWorkout):
        workoutTitle = healthKitWorkout.workoutActivityType.name
        titleTextField.text = workoutTitle
      case .right:
        workoutTitle = "\(Date().in(region: .current).toFormat("MM/dd")) steps"
        titleTextField.text = workoutTitle
      }
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
  }
  
  // MARK: Actions
  
  @objc private func nextTapped() {
    let enterWorkoutDataViewController = EnterWorkoutDataViewController(
      title: workoutTitle ?? "Workout",
      description: workoutDescription,
      media: media,
      healthAppSource: healthAppSource,
      place: place
    )
    
    enterWorkoutDataViewController.delegate = delegate
  
    push(enterWorkoutDataViewController)
  }
  
  @objc private func titleChanged() {
    workoutTitle = titleTextField.text
  }
  
  @IBAction private func tappedHealthApp(_ sender: Any) {
//    presentSourceAlert(source: healthAppSource) { [self] in
//      healthService.requestWorkoutAuthorization()
//        .subscribe(onSuccess: { _ in
//          DispatchQueue.main.async {
//            let importWorkoutViewController = ImportWorkoutViewController()
//            importWorkoutViewController.delegate = self
//
//            self.presentForClose(importWorkoutViewController)
//          }
//        }, onError: { error in
//          DispatchQueue.main.async {
//            let importWorkoutViewController = ImportWorkoutViewController()
//            importWorkoutViewController.delegate = self
//
//            self.presentForClose(importWorkoutViewController)
//          }
//        })
//        .disposed(by: disposeBag)
//    } clear: { [self] in
//      self.healthAppSource = nil
//    }
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
  
  // MARK: Update view
  
  private func updateViewFromState() {
//    guard isViewLoaded else { return }
//
//    let hasTitle =  (workoutTitle ?? "").isNotEmpty
//    let hasHealthAppSource = healthAppSource != nil
//    let hasMedia = media.isNotEmpty
//    let hasLocation = place != nil
//
//    nextButton.isEnabled = hasTitle && (hasHealthAppSource || hasMedia)
//    healthAppCheckbox.image = hasHealthAppSource ? .checked : .notChecked
//    mediaCheckbox.image = hasMedia ? .checked : .notChecked
//    locationCheckbox.image = hasLocation ? .checked : .notChecked
//    healthAppCheckbox.tintColor = hasHealthAppSource ? .brand : .primaryText
//    mediaCheckbox.tintColor = hasMedia ? .brand : .primaryText
//    locationCheckbox.tintColor = hasLocation ? .brand : .primaryText
//
//    if hasHealthAppSource && !hasMedia {
//      sourceDetailsLabel.text = "Verified using Apple Health. Optionally add a photo or video."
//    } else if !hasHealthAppSource && hasMedia {
//      sourceDetailsLabel.text = "Verified using visual evidence. Optionally import a workout from Apple Health."
//    } else if hasHealthAppSource && hasMedia && !hasLocation {
//      sourceDetailsLabel.text = "Verified using using Apple Health and visual evidence. Optionally tag a location."
//    } else if hasHealthAppSource && hasMedia && hasLocation {
//      sourceDetailsLabel.text = "Fully verified."
//    } else {
//      sourceDetailsLabel.text = "Either a workout imported from Apple Health or visual evidence is required for proof."
//    }
//
//    if let healthAppSource = healthAppSource {
//      switch healthAppSource {
//      case .left(let healthKitWorkout):
//        let duration = Int(healthKitWorkout.duration / 60)
//
//        healthAppButton.setTitle("\(healthKitWorkout.workoutActivityType.name) - \(duration) minutes", for: .normal)
//      case .right(let steps):
//        let content = [
//          numberFormatter.string(from: NSDecimalNumber(value: steps)),
//          "steps"
//        ]
//        .compactMap { $0 }
//        .joined(separator: " ")
//
//        healthAppButton.setTitle(content, for: .normal)
//      }
//    } else {
//      healthAppButton.setTitle("Import from Apple Health", for: .normal)
//      healthAppButton.tintColor = .primaryText
//      healthAppButton.setTitleColor(.primaryText, for: .normal)
//    }
//
//    if let place = place {
//      locationButton.setTitle("\(place.name)", for: .normal)
//    } else {
//      locationButton.setTitle("Tag a location", for: .normal)
//      locationButton.tintColor = .primaryText
//      locationButton.setTitleColor(.primaryText, for: .normal)
//    }
//
//    if media.isEmpty {
//      photoOrVideoButton.setTitle("Select photo or video", for: .normal)
//      photoOrVideoButton.tintColor = .primaryText
//      photoOrVideoButton.setTitleColor(.primaryText, for: .normal)
//    } else {
//      let photos = media.filter { item -> Bool in
//        switch item {
//        case .photo: return true
//        case .video: return false
//        }
//      }
//
//      let videos = media.filter { item -> Bool in
//        switch item {
//        case .photo: return false
//        case .video: return true
//        }
//      }
//
//      let p = photos.isNotEmpty ? "\(photos.count) photo\(photos.count == 1 ? "" : "s")" : nil
//      let v = videos.isNotEmpty ? "\(videos.count) video\(videos.count == 1 ? "" : "s")" : nil
//      let content = [p, v].compactMap { $0 }.joined(separator: ", ")
//
//      photoOrVideoButton.setTitle("\(content) selected", for: .normal)
//    }
//
//    if let medium = media.first {
//      previewImageView.image = medium.photo ?? medium.thumbnail
//    } else if let healthAppSource = healthAppSource {
//      switch healthAppSource {
//      case .left(let workout):
//        previewImageView.image = workout.workoutActivityType.activityify.icon
//      case .right(let stepCount):
//        previewImageView.image = ImageGenerator.generateStepImage(steps: stepCount)
//      }
//    } else {
//      previewImageView.image = UIImage(color: .primaryText)
//    }
  }
}

// MARK: Extensions

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
  func importWorkoutViewController(_ importWorkoutViewController: ImportWorkoutViewController, importedSteps steps: StepCount) {
    self.healthAppSource = .right(steps)
    
    importWorkoutViewController.dismiss(animated: true, completion: nil)
  }

  func importWorkoutViewController(_ importWorkoutViewController: ImportWorkoutViewController, imported workout: HKWorkout) {
    self.healthAppSource = .left(workout)
    
    importWorkoutViewController.dismiss(animated: true, completion: nil)
  }
}
