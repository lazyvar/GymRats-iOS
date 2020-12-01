//
//  ImportWorkoutViewModel.swift
//  GymRats
//
//  Created by mack on 5/4/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import HealthKit
import RxSwift

enum ImportWorkoutRow {
  case workout(HKWorkout)
  case noWorkouts
}

final class ImportWorkoutViewModel: ViewModel {
  private let disposeBag = DisposeBag()
  
  struct Input {
    let viewDidLoad = PublishSubject<Void>()
    let tappedRow = PublishSubject<IndexPath>()
  }

  struct Output {
    let sections = PublishSubject<[ImportWorkoutSection]>()
    let selectedWorkout = PublishSubject<HKWorkout>()
  }

  let input = Input()
  let output = Output()
  
  private let healthService: HealthServiceType
  
  init(healthService: HealthServiceType = HealthService.shared) {
    self.healthService = healthService
    
    let workouts = healthService.allWorkouts()
      .asDriver(onErrorJustReturn: [])
      .asObservable()
      .share()
    
    input.viewDidLoad
      .flatMap { workouts }
      .map { workouts in
        if workouts.isEmpty {
          return [ImportWorkoutSection(model: (), items: [.noWorkouts])]
        } else {
          return [ImportWorkoutSection(model: (), items: workouts.map { ImportWorkoutRow.workout($0) })]
        }
      }
      .bind(to: output.sections)
      .disposed(by: disposeBag)
    
    Observable.combineLatest(input.tappedRow, workouts) { ($0, $1) }
      .map { stuff in
        let (indexPath, workouts) = stuff
        
        return workouts[indexPath.row]
      }
      .bind(to: output.selectedWorkout)
      .disposed(by: disposeBag)
  }
}
