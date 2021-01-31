//
//  GoodGoodNotBadViewController.swift
//  GymRats
//
//  Created by Mack on 1/30/21.
//  Copyright © 2021 Mack Hasz. All rights reserved.
//

import Foundation
import Eureka
import RxSwift
import RxCocoa
import YPImagePicker
import RxOptional
import HealthKit

typealias HealthAppSource = Either<HKWorkout, StepCount>

class GoodGoodNotBadViewController: GRFormViewController {
  private let disposeBag = DisposeBag()

  private var healthAppSource: HealthAppSource? {
    didSet { update() }
  }

  private var media: [YPMediaItem] = [] {
    didSet { update() }
  }

  private var place: Place? {
    didSet { update() }
  }
  
  private lazy var submitButton = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(post))
  private let healthService: HealthServiceType = HealthService.shared

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
      }
    }
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

    TextRow.defaultCellSetup = { cell, row in
      cell.textLabel?.font = .body
      cell.titleLabel?.font = .body
      cell.height = { return 48 }
      cell.tintColor = .brand
    }
    
    let titleRow = WorkoutTitleTextFieldRow("title")
    let descriptionRow = WorkoutDescriptionRow("description")
    let contentSection = Section()
      <<< titleRow
      <<< descriptionRow

    let dataSection = Section() { section in
      section.header = self.header(text: "DATA")
    } <<< durationRow <<< distanceRow <<< stepsRow <<< caloriesRow <<< pointsRow
   
    let workoutTime = DateTimeInlineRow() {
      $0.title = "Date"
      $0.value = Date()
      $0.maximumDate = Date().inDefaultRegion().dateAtEndOf(.day).date // TOOD: Can't add after end date / today
//      $0.minimumDate = Date().inDefaultRegion(). // TODO: Can't add before start date
    }
    .cellSetup { cell, _ in
      cell.tintColor = .brand
    }

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

    let titleRequired = titleRow.rx.value.asObservable().isPresent
    let healthAppPresent = healthRow.rx.value.asObservable().isPresent
    let mediaRequired = mediaRow.rx.value.asObservable().isPresent
    
    Observable.combineLatest(titleRequired, healthAppPresent, mediaRequired)
      .map { title, health, media in
        return title && (health || media)
      }
      .bind(to: submitButton.rx.isEnabled)
      .disposed(by: disposeBag)
        
    form +++ contentSection +++ detailsSection +++ sourcesSection +++ dataSection

    update()
  }
  
  @objc private func post() {
    
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
        let duration = Int(healthKitWorkout.duration / 60)

        healthRow.value = "\(healthKitWorkout.workoutActivityType.name) - \(duration) minutes"
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
}

extension GoodGoodNotBadViewController: LocationPickerViewControllerDelegate {
  func didPickLocation(_ locationPickerViewController: LocationPickerViewController, place: Place) {
    self.place = place
    navigationController?.popViewController(animated: true)
  }
}

extension GoodGoodNotBadViewController: ImportWorkoutViewControllerDelegate {
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
