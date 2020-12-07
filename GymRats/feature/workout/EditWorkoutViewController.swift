//
//  EditWorkoutViewController.swift
//  GymRats
//
//  Created by mack on 12/7/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import Eureka
import RxCocoa

protocol EditWorkoutViewControllerDelegate: class {
  func didEdit(_ editWorkoutViewController: EditWorkoutViewController, workout: Workout)
}

class EditWorkoutViewController: GRFormViewController {
  private let disposeBag = DisposeBag()

  // MARK: State
    
  private let workoutTitle = BehaviorRelay<String?>(value: nil)
  private let workoutDescription = BehaviorRelay<String?>(value: nil)
  private let duration = BehaviorRelay<String?>(value: nil)
  private let distance = BehaviorRelay<String?>(value: nil)
  private let steps = BehaviorRelay<String?>(value: nil)
  private let calories = BehaviorRelay<String?>(value: nil)
  private let points = BehaviorRelay<String?>(value: nil)

  private let workout: Workout
  
  weak var delegate: EditWorkoutViewControllerDelegate?
  
  // MARK: UI
  
  private lazy var saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveWorkout))
  
  init(workout: Workout) {
    self.workout = workout
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    saveButton.tintColor = .brand
    tableView.backgroundColor = .background
    
    navigationItem.rightBarButtonItem = saveButton
    navigationItem.title = "Edit workout"
    navigationItem.largeTitleDisplayMode = .never
        
    LabelRow.defaultCellUpdate = nil
    
    let titleRow = WorkoutTitleTextFieldRow("title") {
      $0.value = workout.title
    }.cellSetup { cell, row in
      cell.textLabel?.font = .body
      cell.height = { return 48 }
      cell.tintColor = .brand
    }

    let descriptionRow = WorkoutDescriptionRow("description") {
      $0.value = workout.description
    }

    let durationRow = TextRow("duration") {
      $0.title = "Duration (mins)"
      $0.placeholder = "-"
      $0.value = workout.duration?.stringify
    }.cellSetup { cell, _ in
      cell.textLabel?.font = .body
      cell.titleLabel?.font = .body
      cell.height = { return 48 }
      cell.tintColor = .brand
      cell.textField.keyboardType = .numberPad
    }

    let distanceRow = TextRow("distance") {
      $0.title = "Distance (miles)"
      $0.placeholder = "-"
      $0.value = workout.distance
    }.cellSetup { cell, _ in
      cell.textLabel?.font = .body
      cell.titleLabel?.font = .body
      cell.height = { return 48 }
      cell.tintColor = .brand
      cell.textField.keyboardType = .decimalPad
    }

    let stepsRow = TextRow("steps") {
      $0.title = "Steps"
      $0.placeholder = "-"
      $0.value = workout.steps?.stringify
    }.cellSetup { cell, _ in
      cell.textLabel?.font = .body
      cell.titleLabel?.font = .body
      cell.height = { return 48 }
      cell.tintColor = .brand
      cell.textField.keyboardType = .numberPad
    }

    let caloriesRow = TextRow("cals") {
      $0.title = "Calories"
      $0.placeholder = "-"
      $0.value = workout.calories?.stringify
    }.cellSetup { cell, _ in
      cell.textLabel?.font = .body
      cell.titleLabel?.font = .body
      cell.height = { return 48 }
      cell.tintColor = .brand
      cell.textField.keyboardType = .numberPad
    }

    let pointsRow = TextRow("points") {
      $0.title = "Points"
      $0.placeholder = "-"
      $0.value = workout.points?.stringify
    }.cellSetup { cell, _ in
      cell.textLabel?.font = .body
      cell.titleLabel?.font = .body
      cell.height = { return 48 }
      cell.tintColor = .brand
      cell.textField.keyboardType = .numberPad
    }
    
    titleRow.rx.value.bind(to: self.workoutTitle).disposed(by: disposeBag)
    descriptionRow.rx.value.bind(to: self.workoutDescription).disposed(by: disposeBag)
    durationRow.rx.value.bind(to: self.duration).disposed(by: disposeBag)
    distanceRow.rx.value.bind(to: self.distance).disposed(by: disposeBag)
    stepsRow.rx.value.bind(to: self.steps).disposed(by: disposeBag)
    caloriesRow.rx.value.bind(to: self.calories).disposed(by: disposeBag)
    pointsRow.rx.value.bind(to: self.points).disposed(by: disposeBag)

    let contentSection = Section()
      <<< titleRow
      <<< descriptionRow

    let dataSection = Section()
    
    if workout.appleWorkoutUuid == nil {
      dataSection
        <<< durationRow
        <<< distanceRow
        <<< caloriesRow
    }

    dataSection
      <<< stepsRow
      <<< pointsRow
    
    workoutTitle.accept(workout.title)
    workoutDescription.accept(workout.description)
    duration.accept(workout.duration?.stringify)
    distance.accept(workout.distance)
    steps.accept(workout.steps?.stringify)
    calories.accept(workout.calories?.stringify)
    points.accept(workout.points?.stringify)

    form
      +++ contentSection
      +++ dataSection
    
    workoutTitle
      .map { !($0 ?? "").isEmpty }
      .bind(to: saveButton.rx.isEnabled)
      .disposed(by: disposeBag)
  }
  
  // MARK: Actions
  
  @objc private func saveWorkout() {
    guard let title = workoutTitle.value, title.isNotEmpty else { return }
    
    let updateWorkout = UpdateWorkout(
      id: workout.id,
      title: title,
      description: workoutDescription.value,
      duration: duration.value?.intify,
      distance: distance.value,
      steps: steps.value?.intify,
      calories: calories.value?.intify,
      points: points.value?.intify
    )

    self.showLoadingBar()
    self.saveButton.isEnabled = false
    
    gymRatsAPI.update(updateWorkout)
      .subscribe(onNext: { [weak self] result in
        guard let self = self else { return }

        self.saveButton.isEnabled = true
        self.hideLoadingBar()

        switch result {
        case .success(let workout):
          self.delegate?.didEdit(self, workout: workout)
        case .failure(let error):
          self.presentAlert(with: error)
        }
      })
      .disposed(by: disposeBag)
  }
}

extension String {
  var intify: Int? {
    return Int(self)
  }
}
