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
      .map { challenge -> (Navigation, Screen) in (.replaceDrawerCenter(animated: true), .activeChallenge(challenge)) }
      .bind(to: output.navigation)
      .disposed(by: disposeBag)

    input.tappedStartChallenge
      .map { challenge -> (Navigation, Screen) in (.presentInNav(animated: true), .createChallenge(self)) }
      .bind(to: output.navigation)
      .disposed(by: disposeBag)
  }
}

extension NoChallengesViewModel: CreateChallengeDelegate {
  func challengeCreated(challenge: Challenge) {
    Challenge.State.all.fetch().ignore(disposedBy: disposeBag)
    UserDefaults.standard.set(challenge.id, forKey: "last_opened_challenge")
    output.navigation.on(.next((.replaceDrawerCenter(animated: true), .activeChallenge(challenge))))
  }
}
