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
    let refresh = PublishSubject<Void>()
    let viewDidLoad = PublishSubject<Void>()
    let selectedItem = PublishSubject<IndexPath>()
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
    let fetchMembers = Observable.merge(input.viewDidLoad, input.refresh)
      .flatMap { gymRatsAPI.getMembers(for: self.challenge) }
      .share()
    
    fetchMembers
      .compactMap { $0.error }
      .bind(to:output.error)
      .disposed(by: disposeBag)

    let members = fetchMembers
      .compactMap { $0.object }
      .share()
    
    members
      .map { members in
        let items = members.map { UpcomingChallengeRow.account($0) } + [UpcomingChallengeRow.invite(self.challenge)]
        
        return [UpcomingChallengeSection(model: "", items: items)]
      }
      .bind(to: output.sections)
      .disposed(by: disposeBag)

    input.selectedItem
      .withLatestFrom(members) { ($0, $1) }
      .filter { $0.row == $1.count }
      .subscribe { _ in
        ChallengeFlow.invite(to: self.challenge)
      }
      .disposed(by: disposeBag)
  }
}
