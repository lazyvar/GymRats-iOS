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
  }
}
//retryButton.onTouchUpInside { [weak self] in
  //    self?.fetchAllChallenges()
  //}.disposed(by: disposeBag)
  //
  //joinChallengeButton.onTouchUpInside { [weak self] in
  //    guard let self = self else { return }
  //
  //    JoinChallenge.presentJoinChallengeModal(on: self)
  //        .subscribe(onNext: { [weak self] _ in
  //            self?.fetchAllChallenges()
  //    }, onError: { [weak self] error in
  //        self?.presentAlert(with: error)
  //    }).disposed(by: self.disposeBag)
  //}.disposed(by: disposeBag)
  //
  //createChallengeButton.onTouchUpInside { [weak self] in
  //    let createChallengeViewController = CreateChallengeViewController()
  //    createChallengeViewController.delegate = self
  //
  //    let nav = UINavigationController(rootViewController: createChallengeViewController)
  //    nav.navigationBar.turnSolidWhiteSlightShadow()
  //
  //    self?.present(nav, animated: true, completion: nil)
  //}.disposed(by: disposeBag)
  //
  //fetchAllChallenges()


  //func challengeCreated(challenge: Challenge) {
  //    UserDefaults.standard.set(challenge.id, forKey: "last_opened_challenge")
  //    self.fetchAllChallenges()
  //}

  //gymRatsAPI.getAllChallenges()
  //    .subscribe(onNext: { [weak self] challenges in
  //        self?.hideLoadingBar()
  //        self?.refresher.endRefreshing()
  //
  //        let activeChallenges = challenges.getActiveAndUpcomingChallenges()
  //
  //        GymRatsApp.coordinator.menu.activeChallenges = activeChallenges
  //        GymRatsApp.coordinator.menu.tableView.reloadData()
  //
  //        if activeChallenges.isEmpty {
  //            self?.showEmptyState(challenges: challenges)
  //        } else {
  //            let challengeId = UserDefaults.standard.integer(forKey: "last_opened_challenge")
  //            let challenge: Challenge
  //
  //            if challengeId != 0 {
  //                challenge = activeChallenges.first(where: { $0.id == challengeId }) ?? activeChallenges[0]
  //            } else {
  //                challenge = activeChallenges[0]
  //            }
  //
  //            GymRatsApp.coordinator.centerActiveOrUpcomingChallenge(challenge)
  //        }
  //
  //        if let notif = GymRatsApp.coordinator.coldStartNotification {
  //            GymRatsApp.coordinator.handleNotification(userInfo: notif)
  //            GymRatsApp.coordinator.coldStartNotification = nil
  //        }
  //    }, onError: { [weak self] error in
  //        self?.refresher.endRefreshing()
  //        self?.hideLoadingBar()
  //        self?.retryButton.isHidden = false
  //    }).disposed(by: disposeBag)
