//
//  ChallengeViewModel.swift
//  GymRats
//
//  Created by mack on 3/11/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import RxSwift

final class ChallengeViewModel: ViewModel {
  
  private let disposeBag = DisposeBag()
  private var challenge: Challenge!
  
  struct Input {
    let viewDidLoad = PublishSubject<Void>()
    let refresh = PublishSubject<Void>()
    let tappedRow = PublishSubject<IndexPath>()
  }
  
  struct Output {
    let spin = PublishSubject<Bool>()
    let sections = PublishSubject<[ChallengeSection]>()
    let error = PublishSubject<Error>()
    let navigation = PublishSubject<(Navigation, Screen)>()
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

    let buckets = memberWorkouts
      .map { members, workouts -> ([Account], [(Date, [Workout])]) in
        let workouts = workouts.object ?? []

        return (members.object ?? [], self.challenge.bucket(workouts))
      }
      .share()
    
    buckets
      .map { members, bucketedWorkouts -> [ChallengeSection] in
        let workouts = bucketedWorkouts.flatMap { $0.1 }
        let banner = ChallengeSection(model: nil, items: [.banner(self.challenge, members, workouts)])
        let workoutSections = bucketedWorkouts
          .map { date, workouts in
            ChallengeSection(model: date, items: workouts.map { ChallengeRow.workout($0) })
          }

        return [banner] + workoutSections
      }
      .bind(to: output.sections)
      .disposed(by: disposeBag)
    
    Observable.combineLatest(input.tappedRow, buckets)
      .compactMap { indexPath, bucketedWorkouts -> (Navigation, Screen)? in
        let section = indexPath.section - 1
        
        guard let dayWorkouts = bucketedWorkouts.1[safe: section] else { return nil }
        guard let workout = dayWorkouts.1[safe: indexPath.row] else { return nil }
        
        return (.push(animated: true), .workout(workout))
      }
      .bind(to: output.navigation)
      .disposed(by: disposeBag)
  }
}
