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
    let presentScreen = PublishSubject<Screen>()
  }

  let input = Input()
  let output = Output()

  init() {
    input.tappedJoinChallenge
      .flatMap { JoinChallenge.presentJoinChallengeModal(on: .topmost()) }
      .ignore(disposedBy: disposeBag)
    
    input.tappedStartChallenge
      .map { _ in Screen.createChallenge(self) }
      .bind(to: output.presentScreen)
      .disposed(by: disposeBag)
  }
}

extension NoChallengesViewModel: CreateChallengeDelegate {
  func challengeCreated(challenge: Challenge) {
  
  }
}
