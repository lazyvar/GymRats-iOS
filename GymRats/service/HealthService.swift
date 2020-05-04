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

enum HealthService {
  static let store = HKHealthStore()
  
  static func requestAuthorization(toShare: Set<HKSampleType>?, read: Set<HKObjectType>?) -> Single<Bool> {
    return Single.create { observer in
      store.requestAuthorization(toShare: toShare, read: read) { (success, error) in
        error.map { observer(.error($0)) } ?? observer(.success(success))
      }
      
      return Disposables.create { }
    }
  }
  
  static func allWorkouts() -> Driver<[HKWorkout]> {
    return Single.create { observer in
      let allWorkouts = HKQuery.predicateForWorkouts(with: .greaterThan, duration: 0)
      let sortByStartDate = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
      let query = HKSampleQuery(sampleType: .workoutType(), predicate: allWorkouts, limit: 100, sortDescriptors: [sortByStartDate]) { _, samples, error in
        if let error = error {
          observer(.error(error))
        } else {
          observer(.success((samples ?? []).compactMap { $0 as? HKWorkout }))
        }
      }

      store.execute(query)
      
      return Disposables.create { }
    }.asDriver(onErrorJustReturn: [])
  }
}
