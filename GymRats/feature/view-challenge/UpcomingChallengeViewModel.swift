//
//  UpcomingChallengeViewModel.swift
//  GymRats
//
//  Created by mack on 4/9/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import RxSwift

final class UpcomingChallengeViewModel: ViewModel {
  private let disposeBag = DisposeBag()
  private var challenge: Challenge!

  struct Input {
    let viewDidLoad = PublishSubject<Void>()
    
  }

  struct Output {
    let sections = PublishSubject<[UpcomingChallengeSection]>()
    let error = PublishSubject<Error>()
    let navigation = PublishSubject<(Navigation, Screen)>()
  }

  let input = Input()
  let output = Output()

  func configure(challenge: Challenge) {
    self.challenge = challenge
  }

  init() {
    input.viewDidLoad
      .flatMap { gymRatsAPI.getMembers(for: self.challenge) }
      .compactMap { $0.object }
      .map { members in
        let items = members.map { UpcomingChallengeRow.account($0) } + [UpcomingChallengeRow.invite(challenge)]
        
        return [UpcomingChallengeSection(model: "", items: items)]
      }
      .bind(to: output.sections)
      .disposed(by: disposeBag)
  }
}
