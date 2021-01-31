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

  private var healthAppSource: HealthAppSource?
  private var media: [YPMediaItem] = []
  private var place: Place?
  private lazy var submitButton = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(post))
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

    let durationRow = TextRow("duration") {
      $0.title = "Duration (mins)"
      $0.placeholder = "-"
    }.cellSetup { cell, _ in
      cell.textField.keyboardType = .numberPad
    }

    let distanceRow = TextRow("distance") {
      $0.title = "Distance (miles)"
      $0.placeholder = "-"
    }.cellSetup { cell, _ in
      cell.textField.keyboardType = .decimalPad
    }

    let stepsRow = TextRow("steps") {
      $0.title = "Steps"
      $0.placeholder = "-"
    }.cellSetup { cell, _ in
      cell.textField.keyboardType = .numberPad
    }

    let caloriesRow = TextRow("cals") {
      $0.title = "Calories"
      $0.placeholder = "-"
    }.cellSetup { cell, _ in
      cell.textField.keyboardType = .numberPad
    }

    let pointsRow = TextRow("points") {
      $0.title = "Points"
      $0.placeholder = "-"
    }.cellSetup { cell, _ in
      cell.textField.keyboardType = .numberPad
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
      $0.title = "Workout time"
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
    
    let sourcesSection = Section() { section in
      section.header = self.header(text: "SOURCES")
    }
    <<< LabelRow() {
      $0.title = "Media"
    }
    .cellSetup { cell, _ in
      cell.selectionStyle = .default
      cell.imageView?.tintColor = .primaryText
      cell.imageView?.image = .photoLibrary
      cell.accessoryType = .disclosureIndicator
    }
    .onCellSelection{ [self] cell, row in
      tableView.deselectRow(at: row.indexPath!, animated: true)
      tappedMedia()
    }
    <<< LabelRow() {
      $0.title = "Apple Health"
    }
    .cellSetup { cell, _ in
      cell.selectionStyle = .default
      cell.imageView?.tintColor = .primaryText
      cell.imageView?.image = .heart
      cell.accessoryType = .disclosureIndicator
    }
    .onCellSelection{ [self] cell, row in
      tableView.deselectRow(at: row.indexPath!, animated: true)
      tappedHealthApp()
    }
    <<< LabelRow() {
      $0.title = "Location"
    }
    .cellSetup { cell, _ in
      cell.selectionStyle = .default
      cell.imageView?.tintColor = .primaryText
      cell.imageView?.image = .map
      cell.accessoryType = .disclosureIndicator
    }
    .onCellSelection{ [self] cell, row in
      tableView.deselectRow(at: row.indexPath!, animated: true)
      tappedLocation()
    }
    
    form +++ contentSection +++ detailsSection +++ sourcesSection +++ dataSection
  }
  
  @objc private func post() {
    
  }
  
  private func tappedHealthApp() {
    presentSourceAlert(source: healthAppSource) { [self] in
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
    } clear: { [self] in
      self.healthAppSource = nil
    }
  }

  private func tappedMedia() {
    presentSourceAlert(source: media) { [self] in
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
    } clear: { [self] in
      self.media = []
    }
  }
  
 private func tappedLocation() {
    presentSourceAlert(source: place) { [self] in
      let locationPickerViewController = LocationPickerViewController()
      locationPickerViewController.delegate = self
      
      push(locationPickerViewController)
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
    
    let change = UIAlertAction(title: "Edit", style: .default) { _ in
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
