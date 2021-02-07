//
//  CreateWorkoutViewController.swift
//  GymRats
//
//  Created by Mack Hasz on 2/6/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation
import Eureka
import RxSwift
import RxCocoa
import YPImagePicker
import RxOptional
import HealthKit
import GradientLoadingBar

typealias HealthAppSource = Either<HKWorkout, StepCount>

protocol CreatedWorkoutDelegate: class {
  func createWorkoutController(created workout: Workout)
}

class CreateWorkoutViewController: GRFormViewController {
  private let disposeBag = DisposeBag()

  private var healthAppSource: HealthAppSource? {
    didSet { update(); updateHealthData() }
  }

  private var media: [YPMediaItem] = [] {
    didSet { update() }
  }

  private var place: Place? {
    didSet { update() }
  }
  
  private lazy var submitButton = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(post))
  private let healthService: HealthServiceType = HealthService.shared

  private let gradientProgressIndicatorView = GradientActivityIndicatorView()
  private var loadingBarWidthConstraint: NSLayoutConstraint?
  
  weak var delegate: CreatedWorkoutDelegate?

  private let numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    
    return formatter
  }()

  init(healthAppSource: HealthAppSource) {
    self.healthAppSource = healthAppSource
    
    if #available(iOS 13.0, *) {
      super.init(style: .insetGrouped)
    } else {
      super.init(style: .grouped)
    }
  }
  
  init(media: [YPMediaItem]) {
    self.media = media
    
    if #available(iOS 13.0, *) {
      super.init(style: .insetGrouped)
    } else {
      super.init(style: .grouped)
    }
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    Track.screen(.createWorkout)
  }
  
  lazy var mediaRow = LabelRow() {
    $0.title = "Media"
  }
  .cellSetup { cell, _ in
    cell.selectionStyle = .default
    cell.imageView?.tintColor = .primaryText
    cell.imageView?.image = .photoLibrary
    cell.accessoryType = .disclosureIndicator
  }
  .onCellSelection{ [self] cell, row in
    self.tableView.deselectRow(at: row.indexPath!, animated: true)
    self.tappedMedia()
  }
  .cellUpdate { cell, row in
    let clear = SwipeAction(style: .destructive, title: "Remove") { _, _, completion in
      self.media = []
      completion?(false)
    }
    
    if self.media.isNotEmpty {
      row.trailingSwipe.actions = [clear]
    } else {
      row.trailingSwipe.actions = []
    }
  }
  
  lazy var healthRow = LabelRow() {
    $0.title = "Apple Health"
  }
  .cellSetup { cell, _ in
    cell.selectionStyle = .default
    cell.imageView?.tintColor = .primaryText
    cell.imageView?.image = .heart
    cell.accessoryType = .disclosureIndicator
  }
  .onCellSelection{ [self] cell, row in
    self.tableView.deselectRow(at: row.indexPath!, animated: true)
    self.tappedHealthApp()
  }
  .cellUpdate { cell, row in
    let clear = SwipeAction(style: .destructive, title: "Remove") { _, _, completion in
      self.healthAppSource = nil
      self.workoutTime.value = Date()
      self.workoutTime.updateCell()
      completion?(false)
    }
    
    if self.healthAppSource != nil {
      row.trailingSwipe.actions = [clear]
    } else {
      row.trailingSwipe.actions = []
    }
  }

  lazy var locationRow = LabelRow() {
    $0.title = "Location"
  }
  .cellSetup { cell, _ in
    cell.selectionStyle = .default
    cell.imageView?.tintColor = .primaryText
    cell.imageView?.image = .map
    cell.accessoryType = .disclosureIndicator
  }
  .onCellSelection{ [self] cell, row in
    self.tableView.deselectRow(at: row.indexPath!, animated: true)
    self.tappedLocation()
  }
  .cellUpdate { cell, row in
    let clear = SwipeAction(style: .destructive, title: "Remove") { _, _, completion in
      self.place = nil
      completion?(false)
    }
    
    if self.place != nil {
      row.trailingSwipe.actions = [clear]
    } else {
      row.trailingSwipe.actions = []
    }
  }

  lazy var durationRow = TextRow("duration") {
    $0.title = "Duration (mins)"
    $0.placeholder = "-"
  }.cellSetup { cell, _ in
    cell.textField.keyboardType = .numberPad
  }

  lazy var distanceRow = TextRow("distance") {
    $0.title = "Distance (miles)"
    $0.placeholder = "-"
  }.cellSetup { cell, _ in
    cell.textField.keyboardType = .decimalPad
  }

  lazy var stepsRow = TextRow("steps") {
    $0.title = "Steps"
    $0.placeholder = "-"
  }.cellSetup { cell, _ in
    cell.textField.keyboardType = .numberPad
  }

  lazy var caloriesRow = TextRow("cals") {
    $0.title = "Calories"
    $0.placeholder = "-"
  }.cellSetup { cell, _ in
    cell.textField.keyboardType = .numberPad
  }

  lazy var pointsRow = TextRow("points") {
    $0.title = "Points"
    $0.placeholder = "-"
  }.cellSetup { cell, _ in
    cell.textField.keyboardType = .numberPad
  }

  let activeChallenges = (Challenge.State.all.state?.object ?? []).getActiveChallenges()
  
  lazy var challengesRow = MultipleSelectorRow<Challenge>() { row in
    let check = RuleClosure<Set<Challenge>> { challenges -> ValidationError? in
      let required = ValidationError(msg: "Select at least 1 challenge.")
      guard let challenges = challenges else { return required }
      
      if challenges.isEmpty {
        return required
      } else {
        return nil
      }
    }

    row.add(rule: check)
    row.title = "Challenges"
    row.options = self.activeChallenges
    row.value = Set(self.activeChallenges)
    row.displayValueFor = { cell in
      guard let value = cell.value else { return nil }

      if value == Set(self.activeChallenges) {
        return "All"
      } else if value.isEmpty {
        return "None"
      } else {
        return Array(value).map { $0.name }.joined(separator: ", ")
      }
    }

    row.onPresent { _, to in
      to.selectableRowSetup = { row in
        row.title = row.selectableValue?.name
        row.cell.tintColor = .brand
      }
      to.view.backgroundColor = .background
      to.tableView.backgroundColor = .background
    }
  }
  .onRowValidationChanged(self.handleRowValidationChange)
  
  lazy var titleRow = WorkoutTitleTextFieldRow("title") { row in
    row.add(rule: RuleRequired(msg: "Title is required."))
  }
  .onRowValidationChanged(self.handleRowValidationChange)

  let descriptionRow = WorkoutDescriptionRow("description")

  let workoutTime = DateTimeInlineRow() {
    $0.title = "Date"
    $0.value = Date()
    $0.maximumDate = Date()
  }
  .cellSetup { cell, _ in
    cell.tintColor = .brand
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupBackButton()
    view.backgroundColor = .background
    tableView.backgroundColor = .background
    submitButton.tintColor = .brand

    navigationItem.largeTitleDisplayMode = .never
    navigationItem.title = "Log workout"
    navigationItem.rightBarButtonItem = submitButton

    if let navigationBar = navigationController?.navigationBar {
      gradientProgressIndicatorView.gradientColors = [UIColor.brand, UIColor.brand.withAlphaComponent(0.15), UIColor.brand.withAlphaComponent(0.45), UIColor.brand.withAlphaComponent(0.75)]
      gradientProgressIndicatorView.translatesAutoresizingMaskIntoConstraints = false
      gradientProgressIndicatorView.layer.cornerRadius = 1.5
      gradientProgressIndicatorView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
      
      navigationBar.addSubview(gradientProgressIndicatorView)
      loadingBarWidthConstraint = gradientProgressIndicatorView.constrainWidth(0)
      loadingBarWidthConstraint?.isActive = true
      
      NSLayoutConstraint.activate([
        gradientProgressIndicatorView.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor),
        gradientProgressIndicatorView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor),
        gradientProgressIndicatorView.heightAnchor.constraint(equalToConstant: 3)
      ])
      
      gradientProgressIndicatorView.fadeOut(duration: 0, completion: nil)
    }
    
    TextRow.defaultCellSetup = { cell, row in
      cell.textLabel?.font = .body
      cell.titleLabel?.font = .body
      cell.height = { return 48 }
      cell.tintColor = .brand
    }

    let contentSection = Section()
      <<< titleRow
      <<< descriptionRow

    let dataSection = Section() { section in
      section.header = self.header(text: "DATA")
    } <<< durationRow <<< distanceRow <<< stepsRow <<< caloriesRow <<< pointsRow

    let detailsSection = Section() { section in
      var header = HeaderFooterView<UILabel>(.class)
      header.height = { 0 }
      
      section.header = header
    } <<< workoutTime
    
    if activeChallenges.count > 1 {
      detailsSection <<< challengesRow
    }
    
    let sourcesSection = Section() { section in
      section.header = self.header(text: "SOURCES")
    } <<< mediaRow <<< healthRow <<< locationRow

    form +++ contentSection +++ detailsSection +++ sourcesSection +++ dataSection

    if let workout = healthAppSource?.left?.workoutActivityType.name {
      titleRow.value = workout
    }
    
    if healthAppSource?.right != nil {
      titleRow.value = "\(Date().in(region: .current).toFormat("M/d")) steps"
    }
    
    titleRow.updateCell()
    
    update()
    updateHealthData()
  }
  
  @objc private func post() {
    guard form.validate().isEmpty else { return }
    guard let challenges = challengesRow.value else { return }
    guard let workoutTitle = titleRow.value else { return }
    guard let occurrence = workoutTime.value else { return }
    
    for challenge in challenges {
      if occurrence.localDateIsLessThanUTCDate(challenge.startDate) {
        presentAlert(title: "Uh-oh", message: "Cannot log a workout that occurred before a challenge's start date.")
        
        return
      }
    }
    
    if healthAppSource == nil && media.isEmpty {
      presentAlert(title: "Uh-oh", message: "Please provide either a photo or video or an Apple Health workout for proof.")

      return
    }
    
    let duration = durationRow.value
    let distance = distanceRow.value
    let steps = stepsRow.value
    let calories = caloriesRow.value
    let points = pointsRow.value
    
    let healthKitWorkout = healthAppSource?.workout
    let dailySteps = healthAppSource?.steps
    
    let device: String? = {
      if let healthKitWorkout = healthKitWorkout {
        return healthKitWorkout.device?.name
      } else if dailySteps != nil {
        return UIDevice.current.model
      } else {
        return nil
      }
    }()
    
    let activityType: Workout.Activity? = {
      if let healthKitWorkout = healthKitWorkout {
        return healthKitWorkout.workoutActivityType.activityify
      } else if dailySteps != nil {
        return .steps
      } else {
        return nil
      }
    }()
    
    let newMedia: Either<[LocalMedium], [NewWorkout.Medium]> = {
      if let healthAppSource = healthAppSource, media.isEmpty {
        switch healthAppSource {
        case .left(let workout):
          return .right([
            NewWorkout.Medium(
              url: workout.workoutActivityType.activityify.rat,
              thumbnailUrl: nil,
              mediumType: .image
            )
          ])
        case .right(let steps):
          if let image = ImageGenerator.generateStepImage(steps: steps) {
            return .left([image])
          } else {
            return .right([])
          }
        }
      } else {
        return .left(media)
      }
    }()

    let newWorkout = NewWorkout(
      title: workoutTitle,
      description: descriptionRow.value,
      media: newMedia,
      googlePlaceId: place?.id,
      duration: duration.value.map { Int($0) } ?? nil,
      distance: distance.value,
      steps: steps.value.map { Int($0) } ?? nil,
      calories: calories.value.map { Int($0) } ?? nil,
      points: points.value.map { Int($0) } ?? nil,
      appleDeviceName: device,
      appleSourceName: healthKitWorkout?.sourceRevision.source.name,
      appleWorkoutUuid: healthKitWorkout?.uuid.uuidString,
      activityType: activityType,
      occurredAt: occurrence
    )

    UIApplication.shared.beginIgnoringInteractionEvents()
    submitButton.isEnabled = false
    
    let mediaToUpload = newMedia.left ?? []
    
    let progress: StorageService.ProgressBlock? = {
      guard mediaToUpload.isNotEmpty else { return nil }
      
      return { [self] fractionComplete in
        UIView.animate(withDuration: 0.05) {
          loadingBarWidthConstraint?.constant = CGFloat(CGFloat(fractionComplete) * view.frame.width)
        }
      }
    }()
    
    if mediaToUpload.isEmpty {
      loadingBarWidthConstraint?.constant = view.frame.width
    } else {
      title = "Uploading..."
    }
    
    self.gradientProgressIndicatorView.fadeIn()
    
    gymRatsAPI.postWorkout(newWorkout, challenges: Array(challenges).map { $0.id }, progress: progress)
      .subscribe(onNext: { [weak self] result in
        UIApplication.shared.endIgnoringInteractionEvents()
        
        guard let self = self else { return }
        
        self.gradientProgressIndicatorView.fadeOut()
        self.submitButton.isEnabled = true

        switch result {
        case .success(let workout):
          if let healthKitWorkout = self.healthAppSource?.workout {
            DispatchQueue.global().async {
              try? HealthKitWorkoutCache.insert([healthKitWorkout])
            }
          }
          
          Track.event(.workoutLogged)
          StoreService.requestReview()
          self.delegate?.createWorkoutController(created: workout)
        case .failure(let error):
          self.title = "Enter workout data"
          self.presentAlert(with: error)
        }
      })
      .disposed(by: disposeBag)

  }
  
  private func update() {
    if media.isEmpty {
      mediaRow.value = nil
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

      mediaRow.value = content
    }
    
    if let place = place {
      locationRow.value = place.name
    } else {
      locationRow.value = nil
    }

    if let healthAppSource = healthAppSource {
      switch healthAppSource {
      case .left(let healthKitWorkout):
        healthRow.value = "\(healthKitWorkout.workoutActivityType.name)"
      case .right(let steps):
        let content = [
          numberFormatter.string(from: NSDecimalNumber(value: steps)),
          "steps"
        ]
        .compactMap { $0 }
        .joined(separator: " ")

        healthRow.value = content
      }
    } else {
      healthRow.value = nil
    }
    
    [mediaRow, locationRow, locationRow].forEach { row in
      row.updateCell()
    }
  }
  
  private func updateHealthData() {
    for row in [durationRow, distanceRow, caloriesRow, stepsRow] {
      row.cell.isUserInteractionEnabled = true
      row.value = nil
    }

    guard let healthAppSource = healthAppSource else {
      workoutTime.cell.isUserInteractionEnabled = true
      
      return
    }
    
    switch healthAppSource {
    case .left(let workout):
      durationRow.cell.isUserInteractionEnabled = false
      durationRow.value = Int(workout.duration / 60).stringify
      workoutTime.value = workout.startDate
      workoutTime.cell.isUserInteractionEnabled = false

      if let distance = workout.totalDistance {
        distanceRow.cell.isUserInteractionEnabled = false
        distanceRow.value = String(distance.doubleValue(for: .mile()).rounded(places: 2))
      }

      if let calories = workout.totalEnergyBurned {
        caloriesRow.cell.isUserInteractionEnabled = false
        caloriesRow.value = String(Int(calories.doubleValue(for: .kilocalorie()).rounded()))
      }
    case .right(let steps):
      stepsRow.cell.isUserInteractionEnabled = false
      stepsRow.value = String(steps)
      workoutTime.value = Date()
      workoutTime.cell.isUserInteractionEnabled = false
    }
  }
  
  private func tappedHealthApp() {
    healthService.requestWorkoutAuthorization()
      .subscribe(onSuccess: { _ in
        DispatchQueue.main.async {
          let importWorkoutViewController = ImportWorkoutViewController()
          importWorkoutViewController.delegate = self
          
          self.push(importWorkoutViewController)
        }
      }, onError: { error in
        DispatchQueue.main.async {
          let importWorkoutViewController = ImportWorkoutViewController()
          importWorkoutViewController.delegate = self
          
          self.push(importWorkoutViewController)
        }
      })
      .disposed(by: disposeBag)
  }

  private func tappedMedia() {
    let picker = YPImagePicker()
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
  }
  
 private func tappedLocation() {
    let locationPickerViewController = LocationPickerViewController()
    locationPickerViewController.delegate = self
    
    push(locationPickerViewController)
  }
  
  private func header(text: String) -> HeaderFooterView<UILabel> {
    var header = HeaderFooterView<UILabel>(.class)
    header.height = { 36 }
    header.onSetupView = { view, section in
      view.textColor = .brand
      view.font = .details
      view.text = text
    }
    
    return header
  }
  
  private func handleRowValidationChange<T>(cell: UITableViewCell, row: Row<T>) {
    guard let textRowNumber = row.indexPath?.row, var section = row.section else { return }
    
    let validationLabelRowNumber = textRowNumber + 1
    
    while validationLabelRowNumber < section.count && section[validationLabelRowNumber] is ErrorLabelRow {
      section.remove(at: validationLabelRowNumber)
    }

    if row.isValid { return }
    
    for (index, validationMessage) in row.validationErrors.map({ $0.msg }).enumerated() {
      let labelRow = ErrorLabelRow() {
        if #available(iOS 13.0, *) {
          $0.bgColor = .secondarySystemGroupedBackground
        } else {
          $0.bgColor = .white
        }
      }
      .cellSetup { cell, _ in
        cell.errorLabel.text = validationMessage
      }

      section.insert(labelRow, at: validationLabelRowNumber + index)
    }
  }
}

extension CreateWorkoutViewController: LocationPickerViewControllerDelegate {
  func didPickLocation(_ locationPickerViewController: LocationPickerViewController, place: Place) {
    self.place = place
    navigationController?.popViewController(animated: true)
  }
}

extension CreateWorkoutViewController: ImportWorkoutViewControllerDelegate {
  func importWorkoutViewController(_ importWorkoutViewController: ImportWorkoutViewController, importedSteps steps: StepCount) {
    self.healthAppSource = .right(steps)
    navigationController?.popViewController(animated: true)
  }

  func importWorkoutViewController(_ importWorkoutViewController: ImportWorkoutViewController, imported workout: HKWorkout) {
    self.healthAppSource = .left(workout)
    navigationController?.popViewController(animated: true)
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
