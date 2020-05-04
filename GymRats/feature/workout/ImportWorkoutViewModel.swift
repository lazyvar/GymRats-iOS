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
  
  init() {
    let workouts = HealthService.allWorkouts()
      .asObservable()
      .share()
    
    input.viewDidLoad
      .flatMap { workouts }
      .map { workouts in
        return [ImportWorkoutSection(model: (), items: workouts)]
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
