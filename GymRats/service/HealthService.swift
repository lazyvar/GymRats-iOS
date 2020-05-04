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
}
