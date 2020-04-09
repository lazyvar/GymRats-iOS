//
//  WorkoutViewModel.swift
//  GymRats
//
//  Created by mack on 4/8/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import RxSwift

final class WorkoutViewModel: ViewModel {
  private let disposeBag = DisposeBag()
  private var workout: Workout!
  
  struct Input {
    let viewDidLoad = PublishSubject<Void>()
    let tappedRow = PublishSubject<IndexPath>()
  }
  
  struct Output {
    let sections = PublishSubject<[WorkoutSection]>()
    let error = PublishSubject<Error>()
    let navigation = PublishSubject<(Navigation, Screen)>()
  }
  
  let input = Input()
  let output = Output()
  
  func configure(workout: Workout) {
    self.workout = workout
  }
  
  init() {
    input.viewDidLoad
      .map { _ -> [WorkoutSection] in
        return [
          .init(model: (), items: [.header(self.workout)])
        ]
      }
      .bind(to: output.sections)
      .disposed(by: disposeBag)
  }
}
