//
//  NoChallengesViewModel.swift
//  GymRats
//
//  Created by mack on 3/10/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import RxSwift

final class NoChallengesViewModel: ViewModel {

  private let disposeBag = DisposeBag()

  struct Input {
    let tappedJoinChallenge = PublishSubject<Void>()
    let tappedStartChallenge = PublishSubject<Void>()
  }

  struct Output {
    let navigation = PublishSubject<(Navigation, Screen)>()
  }

  let input = Input()
  let output = Output()

  init() {
    input.tappedJoinChallenge
      .flatMap { _ in ChallengeFlow.join() }
      .do(onNext: { challenge in
        if challenge.isPast {
          UIViewController.topmost().presentAlert(title: "Challenge completed", message: "You have joined a challenge that has already completed.")
        }
      })
      .filter { !$0.isPast }
      .do(onNext: { challenge in
        UserDefaults.standard.set(challenge.id, forKey: "last_opened_challenge")
      })
      .map { challenge -> (Navigation, Screen) in
        if challenge.isActive {
          return (.replaceDrawerCenter(animated: true), .activeChallenge(challenge))
        } else {
          return (.replaceDrawerCenterInNav(animated: true), .upcomingChallenge(challenge))
        }
      }
      .bind(to: output.navigation)
      .disposed(by: disposeBag)

    input.tappedStartChallenge
      .map { challenge -> (Navigation, Screen) in (.presentInNav(animated: true), .createChallenge) }
      .bind(to: output.navigation)
      .disposed(by: disposeBag)
  }
}

//extension NoChallengesViewModel: CreateChallengeDelegate {
//  func challengeCreated(challenge: Challenge) {
//    Challenge.State.all.fetch().ignore(disposedBy: disposeBag)
//    UserDefaults.standard.set(challenge.id, forKey: "last_opened_challenge")
//
//    if challenge.isActive {
//      output.navigation.on(.next((.replaceDrawerCenter(animated: true), .activeChallenge(challenge))))
//    } else {
//      output.navigation.on(.next((.replaceDrawerCenterInNav(animated: true), .upcomingChallenge(challenge))))
//    }
//  }
//}
