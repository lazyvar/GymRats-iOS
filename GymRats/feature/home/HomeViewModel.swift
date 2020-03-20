//
//  HomeViewModel.swift
//  GymRats
//
//  Created by mack on 3/10/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import RxSwift

final class HomeViewModel: ViewModel {
  
  private let disposeBag = DisposeBag()
  
  struct Input {
    let viewDidLoad = PublishSubject<Void>()
  }
  
  struct Output {
    let error = PublishSubject<Error>()
    let navigation = PublishSubject<(Navigation, Screen)>()
  }
  
  let input = Input()
  let output = Output()
  
  init() {
    let challenges = input.viewDidLoad
      .flatMap { _ in Challenge.State.all.fetch() }
      .observeOn(MainScheduler.instance)
      .share()
    
    challenges
      .compactMap { $0.error }
      .bind(to: output.error)
      .disposed(by: disposeBag)
    
    Observable.merge(challenges, Challenge.State.all.observe())
      .compactMap { $0.object }
      .map { $0.filter { $0.isActive || $0.isUpcoming } }
      .map { challenges -> (Navigation, Screen) in
        guard challenges.isNotEmpty else { return (.replaceDrawerCenterInNav(animated: false), .noChallenges) }
        
        let challengeId = UserDefaults.standard.integer(forKey: "last_opened_challenge")
        let challenge = challenges.first { $0.id == challengeId } ?? challenges.first!
        
        if challenge.isActive {
          return (.replaceDrawerCenter(animated: false), .activeChallenge(challenge))
        } else {
          return (.replaceDrawerCenterInNav(animated: false), .upcomingChallenge(challenge))
        }
      }
      .do(onNext: { _ in
        GymRats.handleColdStartNotification()
      })
      .bind(to: output.navigation)
      .disposed(by: disposeBag)
  }
}