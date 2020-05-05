//
//  CreateWorkoutViewController.swift
//  GymRats
//
//  Created by Mack Hasz on 2/6/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import GooglePlaces
import Eureka
import HealthKit

protocol CreatedWorkoutDelegate: class {
  func createWorkoutController(_ createWorkoutController: CreateWorkoutViewController, created workout: Workout)
}

class CreateWorkoutViewController: GRFormViewController {
    weak var delegate: CreatedWorkoutDelegate?

    let disposeBag = DisposeBag()
    let placeLikelihoods = BehaviorRelay<[Place]>(value: [])
    let place = BehaviorRelay<Place?>(value: nil)
    
    let workoutDescription = BehaviorRelay<String?>(value: nil)
    let workoutTitle = BehaviorRelay<String?>(value: nil)
    let photo = BehaviorRelay<UIImage?>(value: nil)
    
    let duration = BehaviorRelay<String?>(value: nil)
    let distance = BehaviorRelay<String?>(value: nil)
    let steps = BehaviorRelay<String?>(value: nil)
    let calories = BehaviorRelay<String?>(value: nil)
    let points = BehaviorRelay<String?>(value: nil)

    lazy var workoutDescriptionThing = self.workoutHeader.map { $0?.description }
    lazy var workoutTitleThing = self.workoutHeader.map { $0?.title }
    lazy var photoThing = self.workoutHeader.map { $0?.image }

    let workoutHeader = BehaviorRelay<WorkoutHeaderInfo?>(value: nil)
    
    var challenges: [Int: BehaviorRelay<Bool>] = [:]
    var image: UIImage?
    var healthKitWorkout = BehaviorRelay<HKWorkout?>(value: nil)
  
    lazy var submitButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(postWorkout))
    lazy var cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissSelf))

    let placeRow = PushRow<Place>() {
        $0.title = "Current Location"
        $0.selectorTitle = "Where are you?"
    }
    .cellSetup { cell, _ in
        cell.tintColor = .primaryText
        cell.height = { return 48 }
        cell.textLabel?.font = .body
        cell.detailTextLabel?.font = .body
    }
    .onPresent { _, selector in
        selector.enableDeselection = false
    }
    
    lazy var placeButtonRow = ButtonRow("place") {
        $0.title = "Check in location"
    }.cellSetup { cell, _ in
        cell.textLabel?.font = .body
        cell.tintColor = .primaryText
        cell.height = { return 48 }
    }.onCellSelection { [weak self] _, _ in
        self?.pickPlace()
        self?.showLoadingBar()
    }
    
  init(source: Either<UIImage, HKWorkout>) {
    self.image = source.left
    self.healthKitWorkout.accept(source.right)
    
    super.init(nibName: nil, bundle: nil)
  }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        submitButton.tintColor = .brand
        navigationItem.rightBarButtonItem = submitButton
        navigationItem.leftBarButtonItem = cancelButton

        title = "Log workout"
        
        tableView.backgroundColor = .background

      navigationItem.largeTitleDisplayMode = .never
      
      LabelRow.defaultCellUpdate = nil

      let activeChallenges = (Challenge.State.all.state?.object ?? []).getActiveChallenges()
      
        let headerRow = CreateWorkoutHeaderRow("workout_header") {
          $0.value = WorkoutHeaderInfo(image: image, title: "", description: "")
        }

        let durationRow = TextRow("duration") {
          $0.title = "Duration (mins)"
          $0.placeholder = "-"
          
          if let duration = healthKitWorkout.value?.duration {
            $0.value = Int(duration / 60).stringify
            $0.baseCell.isUserInteractionEnabled = false
            $0.cell.textField.delegate = self
          }
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
          
          if let distance = healthKitWorkout.value?.totalDistance {
            $0.value = String(Int(distance.doubleValue(for: .mile()).rounded()))
            $0.baseCell.isUserInteractionEnabled = false
            $0.cell.textField.delegate = self
          }
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
          
          if let calories = healthKitWorkout.value?.totalEnergyBurned {
            $0.value = String(Int(calories.doubleValue(for: .kilocalorie()).rounded()))
            $0.baseCell.isUserInteractionEnabled = false
            $0.cell.textField.delegate = self
          }
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
        }.cellSetup { cell, _ in
            cell.textLabel?.font = .body
            cell.titleLabel?.font = .body
            cell.height = { return 48 }
            cell.tintColor = .brand
            cell.textField.keyboardType = .numberPad
        }

        let challengeSection = Section("Challenges")
      
        let headerSection = Section() {
          $0.tag = "the-form"
        }
        <<< headerRow
        <<< placeButtonRow
          
      let dataSection = Section("Data") { $0.tag = "data" }
          <<< durationRow
          <<< distanceRow
          <<< stepsRow
          <<< caloriesRow
          <<< pointsRow
      
      let importDataRow = ButtonRow("import-data") {
        $0.title = "Import data from Apple Health App"
      }.cellSetup { cell, _ in
          cell.textLabel?.font = .body
          cell.tintColor = .primaryText
          cell.height = { return 48 }
          cell.imageView?.image = .smallAppleHealth
      }.onCellSelection { [weak self] _, _ in
        self?.importWorkout()
      }.cellUpdate { cell, row in
        cell.textLabel?.textAlignment = .left
      }
      
      if let workout = healthKitWorkout.value {
        dataSection <<< importedWorkoutRow(workout: workout)
      } else {
        dataSection <<< importDataRow
      }
      
      form +++ headerSection
      form +++ dataSection
      
        activeChallenges.forEach { challenge in
            let row = SwitchRow("challenge_\(challenge.id)") {
                $0.title = "\(challenge.name)"
                $0.value = true
            }.cellSetup { cell, _ in
                cell.height = { return 48 }
            }
            
            let relay = BehaviorRelay(value: true)
            row.rx.value.map { $0 ?? true }.bind(to: relay).disposed(by: disposeBag)
            self.challenges[challenge.id] = relay
            
            challengeSection <<< row
        }
        
        if activeChallenges.count > 1 {
            form +++ challengeSection
        }
        
        placeLikelihoods.asObservable()
            .subscribe { [weak self] event in
                switch event {
                case .next(let val):
                    self?.placeRow.options = val
                    self?.placeRow.value = val.first
                    self?.placeRow.reload()
                case .error:
                    // TODO
                    break
                default:
                    break
                }
            }.disposed(by: disposeBag)
        
        headerRow.rx.value.bind(to: self.workoutHeader).disposed(by: disposeBag)
        
        durationRow.rx.value.bind(to: self.duration).disposed(by: disposeBag)
        distanceRow.rx.value.bind(to: self.distance).disposed(by: disposeBag)
        stepsRow.rx.value.bind(to: self.steps).disposed(by: disposeBag)
        caloriesRow.rx.value.bind(to: self.calories).disposed(by: disposeBag)
        pointsRow.rx.value.bind(to: self.points).disposed(by: disposeBag)

        workoutDescriptionThing.bind(to: workoutDescription).disposed(by: disposeBag)
        workoutTitleThing.bind(to: workoutTitle).disposed(by: disposeBag)
        photoThing.bind(to: photo).disposed(by: disposeBag)
        placeRow.rx.value.bind(to: self.place).disposed(by: disposeBag)
        
        let titlePresent = self.workoutTitle.asObservable().isPresent
        let photoPresent = self.photo.asObservable().isPresent
        let healthAppWorkoutPresent = self.healthKitWorkout.asObservable().isPresent
        let atLeastOneChallenge = Observable<Bool>.combineLatest(self.challenges.values) { vals in
            return vals.reduce(false) { $0 || $1 }
        }
        
        Observable<Bool>.combineLatest(titlePresent, photoPresent, healthAppWorkoutPresent, atLeastOneChallenge) { titlePresent, photoPresent, healthAppWorkoutPresent, atLeastOneChallenge in
            return titlePresent && (photoPresent || healthAppWorkoutPresent) && atLeastOneChallenge
        }
        .bind(to: self.submitButton.rx.isEnabled).disposed(by: disposeBag)
    }
    
    var locationManager: CLLocationManager?
    
    func pickPlace() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        locationManager?.requestWhenInUseAuthorization()
    }
    
    func getPlacesForCurrentLocation() {
        let fields: GMSPlaceField = GMSPlaceField(rawValue:
          UInt(GMSPlaceField.name.rawValue)
          | UInt(GMSPlaceField.placeID.rawValue)
        )!
        
        GMSPlacesClient.shared().findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: fields, callback: { [weak self] placeLikelihoods, error in
            self?.hideLoadingBar()
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
                return
            }
            
            guard
              let self = self,
              let places = placeLikelihoods?.sorted(by: { $0.likelihood > $1.likelihood }).map({ Place(from: $0.place) })
            else { return }

            self.form.sectionBy(tag: "the-form")?.remove(at: 1) // yikes
            var section = self.form.sectionBy(tag: "the-form")
            section?.insert(self.placeRow, at: 1)
  
            var seen: [String: Bool] = [:]
          
          self.placeLikelihoods.accept(places.compactMap { p in p }.filter { seen.updateValue(true, forKey: $0.name) == nil })
        })
    }
  
  func importWorkout() {
    let importWorkoutViewController = ImportWorkoutViewController()
    importWorkoutViewController.delegate = self
    
    self.present(importWorkoutViewController)
  }
  
    @objc func postWorkout() {
      guard (title.value ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isNotEmpty else { presentAlert(title: "Uh-oh", message: "A title is required."); return }

      showLoadingBar(disallowUserInteraction: true)
        
      let challenges = self.challenges
          .filter { $0.value.value }
          .map { $0.key }
      
      let newWorkout = NewWorkout(
        title: workoutTitle.value!,
        description: workoutDescription.value,
        photo: photo.value,
        googlePlaceId: place.value?.id,
        duration: duration.value.map { Int($0) } ?? nil,
        distance: distance.value,
        steps: steps.value.map { Int($0) } ?? nil,
        calories: calories.value.map { Int($0) } ?? nil,
        points: points.value.map { Int($0) } ?? nil
      )
      
      gymRatsAPI.postWorkout(newWorkout, challenges: challenges)
        .subscribe(onNext: { [weak self] result in
          guard let self = self else { return }
          
          self.hideLoadingBar()
          
          switch result {
          case .success(let workout):
            Track.event(.workoutLogged)
            StoreService.requestReview()
            self.delegate?.createWorkoutController(self, created: workout)
          case .failure(let error):
            self.presentAlert(with: error)
          }
        })
        .disposed(by: disposeBag)
    }
  
  func importedWorkoutRow(workout: HKWorkout) -> LabelRow {
    return LabelRow() {
      $0.title = "\(workout.workoutActivityType.name) | \(workout.sourceRevision.source.name)"
      $0.baseCell.textLabel?.numberOfLines = 0
      $0.cell.imageView?.image = .smallAppleHealth

      if let calories = healthKitWorkout.value?.totalEnergyBurned {
        form.rowBy(tag: "cals")?.value = String(Int(calories.doubleValue(for: .kilocalorie()).rounded()))
        form.rowBy(tag: "cals")?.baseCell.isUserInteractionEnabled = false
        (form.rowBy(tag: "cals")?.baseCell as? TextCell)?.textField.delegate = self
      }
      
      if let distance = healthKitWorkout.value?.totalDistance {
        form.rowBy(tag: "distance")?.value = String(Int(distance.doubleValue(for: .mile()).rounded()))
        form.rowBy(tag: "distance")?.baseCell.isUserInteractionEnabled = false
        (form.rowBy(tag: "distance")?.baseCell as? TextCell)?.textField.delegate = self
      }
      
      if let duration = healthKitWorkout.value?.duration {
        form.rowBy(tag: "duration")?.value = Int(duration / 60).stringify
        form.rowBy(tag: "duration")?.baseCell.isUserInteractionEnabled = false
        (form.rowBy(tag: "duration")?.baseCell as? TextCell)?.textField.delegate = self
      }
    }
  }
}

extension CreateWorkoutViewController: ImportWorkoutViewControllerDelegate {
  func importWorkoutViewController(_ importWorkoutViewController: ImportWorkoutViewController, imported workout: HKWorkout) {
    importWorkoutViewController.dismissSelf()
    healthKitWorkout.accept(workout)
    
    form.sectionBy(tag: "data")?.remove(at: 5) // yikes
    var section = self.form.sectionBy(tag: "data")
    section?.insert(self.importedWorkoutRow(workout: workout), at: 5)
  }
}

extension CreateWorkoutViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .authorizedWhenInUse, .authorizedAlways:
      getPlacesForCurrentLocation()
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

extension CreateWorkoutViewController: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    return false
  }
}
