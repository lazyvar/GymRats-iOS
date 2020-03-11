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
  }
  
  struct Output {
    let workouts = PublishSubject<Workout>()
    let error = PublishSubject<Error>()
    let pushScreen = PublishSubject<Screen>()
  }
  
  let input = Input()
  let output = Output()
  
  func configure(challenge: Challenge) {
    self.challenge = challenge
  }
  
  init() {
    input.viewDidLoad
      .flatMap { gymRatsAPI.getWorkouts(for: self.challenge) }
      .debug()
      .debug()
      .debug()
      .ignore(disposedBy: disposeBag)
  }
}
