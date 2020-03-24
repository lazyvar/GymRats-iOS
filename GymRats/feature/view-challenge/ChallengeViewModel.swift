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
  private var page = 0
  
  struct Input {
    let viewDidLoad = PublishSubject<Void>()
    let refresh = PublishSubject<Void>()
    let tappedRow = PublishSubject<IndexPath>()
    let infiniteScrollTriggered = PublishSubject<Void>()
  }
  
  struct Output {
    let loading = PublishSubject<Bool>()
    let sections = PublishSubject<[ChallengeSection]>()
    let error = PublishSubject<Error>()
    let navigation = PublishSubject<(Navigation, Screen)>()
    let resetNoMore = PublishSubject<Void>()
    let doneLoadingMore = PublishSubject<Int?>()
  }
  
  let input = Input()
  let output = Output()
  
  func configure(challenge: Challenge) {
    self.challenge = challenge
  }
  
  enum Action {
    case replace([Workout])
    case append([Workout])
  }
  
  init() {
    let workoutCreated = NotificationCenter.default.rx.notification(.workoutCreated).map { _ in () }
    let workoutDeleted = NotificationCenter.default.rx.notification(.workoutDeleted).map { _ in () }
    let cleanRefresh = Observable.merge(input.refresh, workoutCreated, workoutDeleted, input.viewDidLoad)
    
    let cleanRefreshWorkouts = cleanRefresh
      .do(onNext: { self.page = 0 })
      .flatMap { gymRatsAPI.getWorkouts(for: self.challenge, page: self.page) }
      .share()
    
    let loadNextPage = input.infiniteScrollTriggered
      .do(onNext: { self.page += 1 })
      .flatMap { gymRatsAPI.getWorkouts(for: self.challenge, page: self.page) }
      .share()

    let memberFetch = Observable.merge(input.viewDidLoad, input.refresh)
      .flatMap { gymRatsAPI.getMembers(for: self.challenge) }
      .share()
    
    let members = memberFetch.compactMap { $0.object }

    cleanRefresh.map { _ in () }
      .bind(to: output.resetNoMore)
      .disposed(by: disposeBag)
    
    Observable.merge(cleanRefreshWorkouts, loadNextPage).map { _ in false }
      .bind(to: output.loading)
      .disposed(by: disposeBag)
    
    Observable.merge(memberFetch.map { $0.error }, Observable.merge(cleanRefreshWorkouts, loadNextPage).map { $0.error })
      .compactMap { $0 }
      .bind(to: output.error)
      .disposed(by: disposeBag)
    
    let refreshAction = cleanRefreshWorkouts
      .compactMap { $0.object }
      .map { Action.replace($0) }
    
    let workoutsAction = loadNextPage
      .compactMap { $0.object }
      .map { Action.append($0) }

    let workouts = Observable.merge(refreshAction, workoutsAction)
      .scan([]) { acc, action -> [Workout] in
        switch action {
        case .replace(let workouts): return workouts
        case .append(let workouts): return acc + workouts
        }
      }
      .share()
    
    loadNextPage
      .map { $0.object?.count }
      .bind(to: output.doneLoadingMore)
      .disposed(by: disposeBag)

    let bucketsYWorkouts = workouts.map { (self.challenge.bucket($0), $0) }
    
    Observable.combineLatest(members, bucketsYWorkouts)
      .map { members, bucketsYWorkouts -> [ChallengeSection] in
        let bucketedWorkouts = bucketsYWorkouts.0
        let workouts = bucketsYWorkouts.1
        let banner = ChallengeSection(model: nil, items: [.banner(self.challenge, members, workouts)])
        let workoutSections = bucketedWorkouts
          .map { date, workouts in
            ChallengeSection(model: date, items: workouts.map { ChallengeRow.workout($0) })
          }
        let noWorkouts  = ChallengeSection(model: nil, items: [
          ChallengeRow.noWorkouts(self.challenge, { WorkoutFlow.logWorkout() })
        ])
        
        return [banner] + workoutSections + (workouts.isEmpty ? [noWorkouts] : [])
      }
      .distinctUntilChanged(==)
      .bind(to: output.sections)
      .disposed(by: disposeBag)
    
    input.tappedRow.withLatestFrom(bucketsYWorkouts, resultSelector: { ($0, $1) })
      .compactMap { indexPath, stuff -> (Navigation, Screen)? in
        let (bucketedWorkouts, _) = stuff
        let section = indexPath.section - 1

        guard let dayWorkouts = bucketedWorkouts[safe: section] else { return nil }
        guard let workout = dayWorkouts.1[safe: indexPath.row] else { return nil }

        return (.push(animated: true), .workout(workout, self.challenge))
      }
      .bind(to: output.navigation)
      .disposed(by: disposeBag)
  }
}
