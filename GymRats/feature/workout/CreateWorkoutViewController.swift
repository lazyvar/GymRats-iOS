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

typealias HealthAppSource = Either<HKWorkout, StepCount>

protocol CreatedWorkoutDelegate: class {
  func createWorkoutController(created workout: Workout)
}

class CreateWorkoutViewController: UIViewController {
  private let disposeBag = DisposeBag()
  
  weak var delegate: CreatedWorkoutDelegate?
  
  // MARK: Outlets
  
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
      sourcesLabel.font = .body
    }
  }
  
  @IBOutlet private weak var sourceDetailsLabel: UILabel! {
    didSet {
      sourceDetailsLabel.textColor = .secondaryText
      sourceDetailsLabel.font = .details
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
  
  // MARK: Services
  
  private let healthService: HealthServiceType = HealthService.shared

  private let numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    
    return formatter
  }()
  
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
    
    if let healthAppSource = healthAppSource {
      switch healthAppSource {
      case .left(let healthKitWorkout):
        workoutTitle = healthKitWorkout.workoutActivityType.name
        titleTextField.text = workoutTitle
      case .right:
        workoutTitle = "\(Date().in(region: .current).toFormat("MM/dd")) steps"
        titleTextField.text = workoutTitle
      }
    } else {
      titleTextField.becomeFirstResponder()
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
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    Track.screen(.createWorkout)
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
    presentSourceAlert(source: healthAppSource) { [self] in
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
      self.healthAppSource = nil
    }
  }
  
  @IBAction private func tappedMedia(_ sender: Any) {
    presentSourceAlert(source: media) { [self] in
      let picker = YPImagePicker()
      picker.didFinishPicking { [self] items, cancelled in
        if cancelled {
          picker.dismiss(animated: true, completion: nil)
          
          return
        }

        func complete() {
          picker.dismiss(animated: true) {
            self.media = items
          }
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
    let hasHealthAppSource = healthAppSource != nil
    let hasMedia = media.isNotEmpty
    let hasLocation = place != nil
  
    nextButton.isEnabled = hasTitle && (hasHealthAppSource || hasMedia)
    healthAppCheckbox.image = hasHealthAppSource ? .checked : .notChecked
    mediaCheckbox.image = hasMedia ? .checked : .notChecked
    locationCheckbox.image = hasLocation ? .checked : .notChecked
    healthAppCheckbox.tintColor = hasHealthAppSource ? .goodGreen : .secondaryText
    mediaCheckbox.tintColor = hasMedia ? .goodGreen : .secondaryText
    locationCheckbox.tintColor = hasLocation ? .goodGreen : .secondaryText
    
    if hasHealthAppSource && !hasMedia {
      sourceDetailsLabel.text = "Verified using a Health app workout. Optionally add a photo or video."
    } else if !hasHealthAppSource && hasMedia {
      sourceDetailsLabel.text = "Verified using a photo or video. Optionally import a workout from the Health app."
    } else if hasHealthAppSource && hasMedia && !hasLocation {
      sourceDetailsLabel.text = "Verified using using a Health app workout and a photo or video. Optionally tag a location."
    } else if hasHealthAppSource && hasMedia && hasLocation {
      sourceDetailsLabel.text = "Fully verified."
    } else {
      sourceDetailsLabel.text = "Either a workout imported from the Health app or a photo or video is required for proof."
    }
    
    if let healthAppSource = healthAppSource {
      switch healthAppSource {
      case .left(let healthKitWorkout):
        let duration = Int(healthKitWorkout.duration / 60)
        
        healthAppButton.setTitle("\(healthKitWorkout.workoutActivityType.name) - \(duration) minutes", for: .normal)
      case .right(let steps):
        let content = [
          numberFormatter.string(from: NSDecimalNumber(value: steps)),
          "steps"
        ]
        .compactMap { $0 }
        .joined(separator: " ")
          
        healthAppButton.setTitle(content, for: .normal)
      }
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
  func importWorkoutViewController(_ importWorkoutViewController: ImportWorkoutViewController, importedSteps steps: StepCount) {
    self.healthAppSource = .right(steps)
    
    importWorkoutViewController.dismiss(animated: true, completion: nil)
  }

  func importWorkoutViewController(_ importWorkoutViewController: ImportWorkoutViewController, imported workout: HKWorkout) {
    self.healthAppSource = .left(workout)
    
    importWorkoutViewController.dismiss(animated: true, completion: nil)
  }
}

extension HealthAppSource {
  var workout: HKWorkout? {
    switch self {
    case .left(let workout): return workout
    case .right: return nil
    }
  }

  var steps: StepCount? {
    switch self {
    case .left: return nil
    case .right(let steps): return steps
    }
  }
}
