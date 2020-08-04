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
    let scrollToTop = PublishSubject<Void>()
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
    let workoutCreated = NotificationCenter.default.rx.notification(.workoutCreated).map { _ in () }.share()
    let workoutDeleted = NotificationCenter.default.rx.notification(.workoutDeleted).map { _ in () }.share()
    let appEnteredForeground = NotificationCenter.default.rx.notification(.appEnteredForeground).map { _ in () }.share()
    
    appEnteredForeground
      .bind(to: output.scrollToTop)
      .disposed(by: disposeBag)
    
    let cleanRefresh = Observable.merge(input.refresh, workoutCreated, workoutDeleted, input.viewDidLoad, appEnteredForeground)
      .share()
    
    let cleanRefreshWorkouts = cleanRefresh
      .do(onNext: { self.page = 0 })
      .flatMap {
        gymRatsAPI.getWorkouts(for: self.challenge, page: self.page)
          .executeFor(atLeast: .milliseconds(300), scheduler: MainScheduler.instance)
      }
      .share()
    
    let loadNextPage = input.infiniteScrollTriggered
      .do(onNext: { self.page += 1 })
      .flatMap { gymRatsAPI.getWorkouts(for: self.challenge, page: self.page) }
      .share()

    let challengeInfoFetch = Observable.merge(cleanRefresh)
      .flatMap { gymRatsAPI.challengeInfo(self.challenge) }
      .share()
    
    let challengeInfo = challengeInfoFetch.compactMap { $0.object }.share()

    cleanRefresh.map { _ in () }
      .bind(to: output.resetNoMore)
      .disposed(by: disposeBag)

    Observable.merge(workoutCreated, workoutDeleted).map { _ in true }
      .bind(to: output.loading)
      .disposed(by: disposeBag)
    
    Observable.merge(cleanRefreshWorkouts, loadNextPage).map { _ in false }
      .bind(to: output.loading)
      .disposed(by: disposeBag)
    
    Observable.merge(challengeInfoFetch.map { $0.error }, Observable.merge(cleanRefreshWorkouts, loadNextPage).map { $0.error })
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
    
    let ghostSections = input.viewDidLoad
      .map { _ -> [ChallengeSection] in
        return [
          .init(model: .init(date: nil, skeleton: false), items: [.banner(self.challenge, ChallengeInfo(memberCount: 0, workoutCount: 0, leader: .dummy, leaderScore: "", currentAccountScore: ""))]),
          .init(model: .init(date: Date(), skeleton: true), items: [.💀(-1000), .💀(-1001), .💀(-1002), .💀(-1003), .💀(-1004), .💀(-1005), .💀(-1006), .💀(-1007), .💀(-1008)])
        ]
      }

    let challengeInfoSection = challengeInfo
      .map { challengeInfo -> [ChallengeSection] in
        let banner = ChallengeSection(model: .init(date: nil, skeleton: false), items: [.banner(self.challenge, challengeInfo)])
        
        return [banner]
      }
    
    let workoutSections = bucketsYWorkouts
      .map { bucketsYWorkouts -> [ChallengeSection] in
          let bucketedWorkouts = bucketsYWorkouts.0
          let workouts = bucketsYWorkouts.1
          let workoutSections = bucketedWorkouts
            .map { date, workouts in
              ChallengeSection(model: .init(date: date, skeleton: false), items: workouts.map { ChallengeRow.workout($0) })
            }
          
          let noWorkouts  = ChallengeSection(model:.init(date: nil, skeleton: false), items: [
            ChallengeRow.noWorkouts(self.challenge)
          ])
          
          return workoutSections + (workouts.isEmpty ? [noWorkouts] : [])
        }
        .distinctUntilChanged(==)
    
    let realSections = Observable.combineLatest(challengeInfoSection, workoutSections)
      .map { $0 + $1 }

    Observable.merge(ghostSections, realSections)
      .bind(to: output.sections)
      .disposed(by: disposeBag)
    
    input.tappedRow
      .filter { $0.section == 0 }
      .map { _ -> (Navigation, Screen) in
        return (.push(animated: true), .challengeDetails(self.challenge))
      }
      .bind(to: output.navigation)
      .disposed(by: disposeBag)

    input.tappedRow
      .filter { $0.section > 0 }
      .withLatestFrom(bucketsYWorkouts, resultSelector: { ($0, $1) })
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
