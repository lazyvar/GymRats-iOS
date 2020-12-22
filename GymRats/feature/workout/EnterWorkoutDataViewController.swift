//
//  EnterWorkoutDataViewController.swift
//  GymRats
//
//  Created by mack on 12/3/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import Eureka
import RxSwift
import RxCocoa
import YPImagePicker
import HealthKit
import GradientLoadingBar

class EnterWorkoutDataViewController: GRFormViewController {
  private let disposeBag = DisposeBag()

  // MARK: State
  
  private var challenges: [Int: BehaviorRelay<Bool>] = [:]
  
  private let duration = BehaviorRelay<String?>(value: nil)
  private let distance = BehaviorRelay<String?>(value: nil)
  private let steps = BehaviorRelay<String?>(value: nil)
  private let calories = BehaviorRelay<String?>(value: nil)
  private let points = BehaviorRelay<String?>(value: nil)

  private let workoutTitle: String
  private let workoutDescription: String?
  private let media: [YPMediaItem]
  private let healthAppSource: HealthAppSource?
  private let place: Place?
  
  weak var delegate: CreatedWorkoutDelegate?
  
  // MARK: UI
  
  private let numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    
    return formatter
  }()

  private let gradientProgressIndicatorView = GradientActivityIndicatorView()
  private lazy var postButton = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(postWorkout))
  private var loadingBarWidthConstraint: NSLayoutConstraint?

  init(title: String, description: String?, media: [YPMediaItem], healthAppSource: HealthAppSource?, place: Place?) {
    self.workoutTitle = title
    self.workoutDescription = description
    self.media = media
    self.healthAppSource = healthAppSource
    self.place = place
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    postButton.tintColor = .brand
    tableView.backgroundColor = .background
    
    navigationItem.rightBarButtonItem = postButton
    navigationItem.title = "Enter workout data"
    navigationItem.largeTitleDisplayMode = .never
    
    let activeChallenges = (Challenge.State.all.state?.object ?? []).getActiveChallenges()
    
    LabelRow.defaultCellUpdate = nil
    
    let durationRow = TextRow("duration") {
      $0.title = "Duration (mins)"
      $0.placeholder = "-"
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
    
    durationRow.rx.value.bind(to: self.duration).disposed(by: disposeBag)
    distanceRow.rx.value.bind(to: self.distance).disposed(by: disposeBag)
    stepsRow.rx.value.bind(to: self.steps).disposed(by: disposeBag)
    caloriesRow.rx.value.bind(to: self.calories).disposed(by: disposeBag)
    pointsRow.rx.value.bind(to: self.points).disposed(by: disposeBag)

    let challengeSection = Section("Challenges")

    for challenge in activeChallenges {
      let row = SwitchRow("challenge_\(challenge.id)") {
        $0.title = "\(challenge.name)"
        $0.value = true
      }.cellSetup { cell, _ in
        cell.height = { return 48 }
        cell.switchControl.onTintColor = .brand
      }
      
      let relay = BehaviorRelay(value: true)
      row.rx.value.map { $0 ?? true }.bind(to: relay).disposed(by: disposeBag)
      self.challenges[challenge.id] = relay
      
      challengeSection <<< row
    }
      
    if activeChallenges.count > 1 {
      form +++ challengeSection
    }

    let dataSection = Section("Data")
    
    if let healthAppSource = healthAppSource {
      switch healthAppSource {
      case .left(let workout):
        durationRow.cell.isUserInteractionEnabled = false
        durationRow.value = Int(workout.duration / 60).stringify
        duration.accept(durationRow.value)
          
        if let distance = workout.totalDistance {
          distanceRow.cell.isUserInteractionEnabled = false
          distanceRow.value = String(distance.doubleValue(for: .mile()).rounded(places: 2))
          self.distance.accept(distanceRow.value)
        }

        if let calories = workout.totalEnergyBurned {
          caloriesRow.cell.isUserInteractionEnabled = false
          caloriesRow.value = String(Int(calories.doubleValue(for: .kilocalorie()).rounded()))
          self.calories.accept(caloriesRow.value)
        }
      case .right(let steps):
        stepsRow.cell.isUserInteractionEnabled = false
        stepsRow.value = String(steps)
        self.steps.accept(String(steps))
      }
    }
    
    dataSection
      <<< durationRow
      <<< distanceRow
      <<< caloriesRow
      <<< stepsRow
      <<< pointsRow
    
    form +++ dataSection

    let atLeastOneChallenge = Observable<Bool>.combineLatest(self.challenges.values) { vals in
      return vals.reduce(false) { $0 || $1 }
    }
      
    atLeastOneChallenge
      .bind(to: self.postButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
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
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    Track.screen(.enterWorkoutData)
  }
  
  // MARK: Actions
  
  @objc private func postWorkout() {
    let challenges = self.challenges
        .filter { $0.value.value }
        .map { $0.key }
    
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
      description: workoutDescription,
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
      occurredAt: nil
    )

    UIApplication.shared.beginIgnoringInteractionEvents()
    self.postButton.isEnabled = false
    
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
    
    gymRatsAPI.postWorkout(newWorkout, challenges: challenges, progress: progress)
      .subscribe(onNext: { [weak self] result in
        UIApplication.shared.endIgnoringInteractionEvents()
        
        guard let self = self else { return }
        
        self.gradientProgressIndicatorView.fadeOut()
        self.postButton.isEnabled = true

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
}
