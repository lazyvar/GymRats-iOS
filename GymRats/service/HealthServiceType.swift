//
//  HealthServiceType.swift
//  GymRats
//
//  Created by mack on 11/29/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import HealthKit
import RxSwift
import RxCocoa

protocol HealthServiceType: class {
  var didShowGymRatsPrompt: Bool { get }
  var autoSyncEnabled: Bool { get set }
  
  func observeWorkouts()
  func markPromptSeen()
  func didRequestWorkoutAuthorization() -> Single<Bool>
  func requestWorkoutAuthorization() -> Single<Bool>
  func allWorkouts() -> Single<[HKWorkout]>
}
