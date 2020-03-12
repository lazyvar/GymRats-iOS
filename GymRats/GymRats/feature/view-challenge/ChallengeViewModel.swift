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
    let spin = PublishSubject<Bool>()
    let sections = PublishSubject<[ChallengeSection]>()
    let error = PublishSubject<Error>()
    let pushScreen = PublishSubject<Screen>()
  }
  
  let input = Input()
  let output = Output()
  
  func configure(challenge: Challenge) {
    self.challenge = challenge
  }
  
  init() {
    let memberWorkouts = Observable.merge(input.viewDidLoad, input.refresh)
      .flatMap { _ in
        Observable.combineLatest(
          gymRatsAPI.getMembers(for: self.challenge),
          gymRatsAPI.getWorkouts(for: self.challenge)
        )
      }
      .share()
    
    input.viewDidLoad.map { _ in true }
      .bind(to: output.spin)
      .disposed(by: disposeBag)

    memberWorkouts.map { _ in false }
      .bind(to: output.spin)
      .disposed(by: disposeBag)
    
    memberWorkouts
      .compactMap { $0.0.error ?? $0.1.error }
      .bind(to: output.error)
      .disposed(by: disposeBag)

    memberWorkouts
      .map { members, workouts -> [ChallengeSection] in
        let workouts = workouts.object ?? []
        let members = members.object ?? []
        let banner = ChallengeSection(model: nil, items: [.banner(self.challenge, members, workouts)])
        let workoutSections = self.challenge
          .bucket(workouts)
          .map { date, workouts in
            ChallengeSection(model: date, items: workouts.map { ChallengeRow.workout($0) })
          }

        return [banner] + workoutSections
      }
      .bind(to: output.sections)
      .disposed(by: disposeBag)
  }
}
