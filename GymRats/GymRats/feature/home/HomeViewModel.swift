//
//  HomeViewModel.swift
//  GymRats
//
//  Created by mack on 3/10/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class HomeViewModel: ViewModel {
  
  private let disposeBag = DisposeBag()
  
  struct Input {
    let viewDidLoad = PublishSubject<Void>()
  }
  
  struct Output {
    let error = PublishSubject<Error>()
    let showEmptyState = PublishSubject<Void>()
    let showChallenge = PublishSubject<Challenge>()
  }
  
  let input = Input()
  let output = Output()
  
  init() {
    let fetchChallenges = input.viewDidLoad
      .flatMap { Challenge.all.fetch() }
      .observeOn(MainScheduler.instance)
      .share()
    
    fetchChallenges
      .compactMap { $0.error }
      .bind(to: output.error)
      .disposed(by: disposeBag)
    
    let challenges = fetchChallenges
      .compactMap { $0.object }
      .share()
    
    challenges
      .filter { $0.isEmpty }
      .map { _ in () }
      .bind(to: output.showEmptyState)
      .disposed(by: disposeBag)
    
    challenges
      .filter { $0.isNotEmpty }
      .compactMap { challenges in
        let challengeId = UserDefaults.standard.integer(forKey: "last_opened_challenge")
        
        return challenges.first { $0.id == challengeId } ?? challenges.first
      }
      .do(onNext: { _ in
        if let notification = GymRatsApp.coordinator.coldStartNotification {
          GymRatsApp.coordinator.handleNotification(userInfo: notification)
          GymRatsApp.coordinator.coldStartNotification = nil
        }
      })
      .bind(to: output.showChallenge)
      .disposed(by: disposeBag)
  }
}
