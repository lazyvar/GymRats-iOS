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
    
  }

  let input = Input()
  let output = Output()

  init() {
    input.tappedJoinChallenge
      .flatMap { JoinChallenge.presentJoinChallengeModal(on: .topmost()) }
      .ignore(disposedBy: disposeBag)
    
    //    let createChallengeViewController = CreateChallengeViewController()
    //    createChallengeViewController.delegate = self
    //
    //    let nav = UINavigationController(rootViewController: createChallengeViewController)
    //    nav.navigationBar.turnSolidWhiteSlightShadow()
    //
    //    self?.present(nav, animated: true, completion: nil)
  }
}
