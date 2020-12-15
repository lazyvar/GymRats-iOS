//
//  HealthService.swift
//  GymRats
//
//  Created by mack on 5/4/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import HealthKit
import RxSwift
import RxCocoa

class HealthService: HealthServiceType {
  static let shared = HealthService()
  
  private enum Key {
    static let prompt = "health_kit_gym_rats_prompt"
    static let autoSync = "health_kit_auto_sync"
    static let lastSyncTime = "health_kit_last_sync_time"
  }
  
  private let disposeBag = DisposeBag()
  private let store = HKHealthStore()
  private let workoutSet = Set([HKObjectType.workoutType()])
  private let stepsSet = Set([HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!])
  private let userDefaults: UserDefaults = .standard

  private var synchronizationInPorgress = false
  private var observationQuery: HKObserverQuery?
  
  var autoSyncEnabled: Bool {
    get {
      return userDefaults.bool(forKey: Key.autoSync)
    }
    set {
      userDefaults.setValue(newValue, forKey: Key.autoSync)

      if newValue {
        lastSync = Date()
        observeWorkouts()
      } else {
        disableBackgroundDelivery()
      }
    }
  }

  var lastSync: Date {
    get {
      userDefaults.codable(forKey: Key.lastSyncTime) ?? Date()
    }
    set {
      userDefaults.setCodable(newValue, forKey: Key.lastSyncTime)
    }
  }
  
  var didShowGymRatsPrompt: Bool {
    return userDefaults.bool(forKey: Key.prompt)
  }
  
  func observeWorkouts() {
    guard observationQuery == nil else { return }
    
    NotificationCenter.default.rx.notification(.appDidBecomeActive)
      .filter    { [self] _ in autoSyncEnabled }
      .flatMap   { [self] _ in uploadUnsynchronizedWorkouts().asObservable() }
      .subscribe { _ in }
      .disposed(by: disposeBag)
    
    observationQuery = HKObserverQuery(
      sampleType: HKObjectType.workoutType(),
      predicate: nil,
      updateHandler: { [self] query, completionHandler, error in
        DispatchQueue.main.async {
          guard !synchronizationInPorgress else { return }
          guard UIApplication.shared.applicationState == .background else { return }
          
          DevLog.autoSyncInitiated()
          synchronizationInPorgress = true
          
          uploadUnsynchronizedWorkouts()
            .subscribe { _ in
              synchronizationInPorgress = false
              completionHandler()
            }
            .disposed(by: disposeBag)
        }
      }
    )
    
    store.execute(observationQuery!)
    store.enableBackgroundDelivery(for: .workoutType(), frequency: .immediate) { success, error in
      print("Enable background delivery success: \(success)")

      if let error = error {
        print("Enable background delivery failed: \(error)")
      }
    }
  }
  
  func markPromptSeen() {
    userDefaults.setValue(true, forKey: Key.prompt)
  }
  
  func didRequestWorkoutAuthorization() -> Single<Bool> {
    return Single.create { [self] observer in
      store.getRequestStatusForAuthorization(toShare: [], read: workoutSet) { status, error in
        DispatchQueue.main.async {
          if let error = error {
            observer(.error(error))
          } else {
            observer(.success(status == .unnecessary))
          }
        }
      }
      
      return Disposables.create()
    }
  }
  
  func requestWorkoutAuthorization() -> Single<Bool> {
    return Single.create { [self] observer in
      store.requestAuthorization(toShare: nil, read: workoutSet) { (success, error) in
        DispatchQueue.main.async {
          error.map { observer(.error($0)) } ?? observer(.success(success))
        }
      }
      
      return Disposables.create()
    }
  }

  func didRequestStepAuthorization() -> Single<Bool> {
    return Single.create { [self] observer in
      store.getRequestStatusForAuthorization(toShare: [], read: stepsSet) { status, error in
        DispatchQueue.main.async {
          if let error = error {
            observer(.error(error))
          } else {
            observer(.success(status == .unnecessary))
          }
        }
      }
      
      return Disposables.create()
    }
  }
  
  func requestStepAuthorization() -> Single<Bool> {
    return Single.create { [self] observer in
      store.requestAuthorization(toShare: nil, read: stepsSet) { (success, error) in
        DispatchQueue.main.async {
          error.map { observer(.error($0)) } ?? observer(.success(success))
        }
      }

      return Disposables.create()
    }
  }

  func todaysStepCount() -> Single<StepCount> {
    return Single.create { [self] observer in
      let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
      let now = Date()
      let startOfDay = Calendar.current.startOfDay(for: now)
      let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

      let query = HKStatisticsQuery(
        quantityType: stepsQuantityType,
        quantitySamplePredicate: predicate,
        options: .cumulativeSum
      ) { _, result, error in
        DispatchQueue.main.async {
          if let error = error {
            observer(.error(error))
          }
          
          if let result = result, let sum = result.sumQuantity() {
            observer(.success(Int(sum.doubleValue(for: HKUnit.count()))))
          } else {
            observer(.error(SimpleError(message: "Could not get step count.")))
          }
        }
      }

      store.execute(query)
      
      return Disposables.create()
    }
  }

  func allWorkouts() -> Single<[HKWorkout]> {
    return Single.create { [self] observer in
      let allWorkouts = HKQuery.predicateForWorkouts(with: .greaterThan, duration: 0)
      let sortByStartDate = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
      let noManualEntryAllowed = NSPredicate(format: "metadata.%K != YES", HKMetadataKeyWasUserEntered)
      let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [allWorkouts, noManualEntryAllowed])
      let query = HKSampleQuery(sampleType: .workoutType(), predicate: compoundPredicate, limit: 100, sortDescriptors: [sortByStartDate]) { _, samples, error in
        DispatchQueue.main.async {
          if let error = error {
            observer(.error(error))
          } else {
            observer(.success((samples ?? []).compactMap { $0 as? HKWorkout }))
          }
        }
      }

      store.execute(query)
      
      return Disposables.create()
    }
  }

  func unsynchronizedWorkouts() -> Single<[HKWorkout]> {
    return Single.create { [self] observer in
      DevLog.fetchingSamples(lastSync: lastSync)
      
      let allWorkouts = HKQuery.predicateForWorkouts(with: .greaterThan, duration: 0)
      let sortByStartDate = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
      let noManualEntryAllowed = NSPredicate(format: "metadata.%K != YES", HKMetadataKeyWasUserEntered)
      let withStartDate = HKQuery.predicateForSamples(withStart: lastSync, end: Date(), options: [])
      let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [allWorkouts, noManualEntryAllowed, withStartDate])
      let query = HKSampleQuery(sampleType: .workoutType(), predicate: compoundPredicate, limit: 100, sortDescriptors: [sortByStartDate]) { _, samples, error in
        lastSync = Date()

        DispatchQueue.main.async {
          if let error = error {
            DevLog.foundError(error)
            observer(.error(error))
          } else {
            let workouts = (samples ?? []).compactMap { $0 as? HKWorkout }
            
            DevLog.foundSamples(samples: workouts, lastSync: lastSync)
            observer(.success(workouts))
          }
        }
      }
      
      store.execute(query)

      return Disposables.create()
    }
  }
  
  private func uploadUnsynchronizedWorkouts() -> Single<Void> {
    let challenges = Challenge.State.all.fetch().map { ($0.object ?? []).getActiveChallenges() }
    let unsynchronizedWorkouts = self.unsynchronizedWorkouts()
      .asObservable()
      .map { try? HealthKitWorkoutCache.filterNotStored($0) }
      .map { $0 ?? [] }

    return Observable.zip(challenges, unsynchronizedWorkouts)
      .do(onNext: { _, workouts in
        try? HealthKitWorkoutCache.insert(workouts)
      })
      .flatMap { challenges, workouts -> Observable<[NetworkResult<Workout>]> in
        return Observable.combineLatest(workouts.map { return self.upload(healthKitWorkout: $0, challenges: challenges) })
      }
      .do(onNext: { _ in
        NotificationCenter.default.post(.workoutCreated)
      })
      .asSingle()
      .map { _ in () }
  }
  
  private func upload(healthKitWorkout: HKWorkout, challenges: [Challenge]) -> Observable<NetworkResult<Workout>> {
    let activityType = healthKitWorkout.workoutActivityType

    var newWorkout = NewWorkout(
      title: activityType.name,
      description: nil,
      media: .right([
        NewWorkout.Medium(
          url: activityType.activityify.rat,
          thumbnailUrl: nil,
          mediumType: .image
        )
      ]),
      googlePlaceId: nil,
      duration: nil,
      distance: nil,
      steps: nil,
      calories: nil,
      points: nil,
      appleDeviceName: healthKitWorkout.device?.name,
      appleSourceName: healthKitWorkout.sourceRevision.source.name,
      appleWorkoutUuid: healthKitWorkout.uuid.uuidString,
      activityType: healthKitWorkout.workoutActivityType.activityify
    )

    if let calories = healthKitWorkout.totalEnergyBurned {
      newWorkout.calories = Int(calories.doubleValue(for: .kilocalorie()).rounded())
    }
    
    if let distance = healthKitWorkout.totalDistance {
      newWorkout.distance = String(distance.doubleValue(for: .mile()).rounded(places: 1))
    }
    
    newWorkout.duration = Int(healthKitWorkout.duration / 60)
    newWorkout.occurredAt = healthKitWorkout.startDate
    
    return gymRatsAPI.postWorkout(newWorkout, challenges: challenges.map { $0.id })
  }

  private func disableBackgroundDelivery() {
    if let observationQuery = observationQuery {
      store.stop(observationQuery)
      self.observationQuery = nil
    }
    
    store.disableBackgroundDelivery(for: .workoutType()) { success, error in
      print("Disable background delivery success: \(success)")

      if let error = error {
        print("Disable background delivery failed: \(error)")
      }
    }
  }
}
