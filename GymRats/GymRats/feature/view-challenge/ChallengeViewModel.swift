//
//  ChallengeViewModel.swift
//  GymRats
//
//  Created by mack on 3/11/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class ChallengeViewModel: ViewModel {
  
  private let disposeBag = DisposeBag()
  private var challenge: Challenge!
  
  struct Input {
    let viewDidLoad = PublishSubject<Void>()
    let refresh = PublishSubject<Void>()
  }
  
  struct Output {
    let workouts = PublishSubject<[Workout]>()
    let error = PublishSubject<Error>()
    let pushScreen = PublishSubject<Screen>()
  }
  
  let input = Input()
  let output = Output()
  
  func configure(challenge: Challenge) {
    self.challenge = challenge
  }
  
  init() {
    let workouts = Observable.merge(input.viewDidLoad, input.refresh)
      .flatMap { _ in gymRatsAPI.getWorkouts(for: self.challenge) }
      .share()
    
    workouts
      .compactMap { $0.error }
      .bind(to: output.error)
      .disposed(by: disposeBag)

    workouts
      .compactMap { $0.object }
      .bind(to: output.workouts)
      .disposed(by: disposeBag)
  }
}
