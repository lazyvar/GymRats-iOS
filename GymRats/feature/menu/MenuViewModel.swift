//
//  MenuViewModel.swift
//  GymRats
//
//  Created by mack on 3/12/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import RxSwift

final class MenuViewModel: ViewModel {
  
  private let disposeBag = DisposeBag()
  
  struct Input {
    let viewDidLoad = PublishSubject<Void>()
    let tappedRow = PublishSubject<IndexPath>()
  }
  
  struct Output {
    let error = PublishSubject<Error>()
    let sections = PublishSubject<[MenuSection]>()
    let navigation = PublishSubject<(Navigation, Screen)>()
  }
  
  let input = Input()
  let output = Output()
  
  init() {
    let profile = Observable<Void>.merge(.just(()), NotificationCenter.default.rx.notification(.currentAccountUpdated).map { _ in () })
      .map { _ in return MenuSection(model: false, items: [.profile(GymRats.currentAccount)]) }

    let challenges = Challenge.State.all.observe()
      .compactMap { $0.object }
      .map { challenges in
        return challenges.filter { $0.isActive || $0.isUpcoming }
      }
      .share()
    
    let challengeSection = Observable.merge(.just([]), challenges)
      .map { challenges -> MenuSection in
        let items: [MenuRow] = challenges.isNotEmpty ? challenges.map { MenuRow.challenge($0) } : [.home]
        
        return .init(model: false, items: items)
      }
    
    let items = Observable<[MenuRow.Item]>.just([.completed, .join, .start, .settings, .about])
      .map { MenuSection(model: true, items: $0.map { MenuRow.item($0) }) }
     
    let stuff = Observable.combineLatest(profile, challengeSection, items)
    let viewDidLoadWithStuff = input.viewDidLoad.withLatestFrom(stuff)
    
    Observable.merge(viewDidLoadWithStuff, stuff)
      .map { things in
        let (profile, challenges, items) = things

        return [profile, challenges, items]
      }
      .bind(to: output.sections)
      .disposed(by: disposeBag)
    
    input.tappedRow
      .filter { $0.section == 2 && $0.row == 1 }
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
      .map { challenge -> (Navigation, Screen) in (.replaceDrawerCenter(animated: true), .activeChallenge(challenge)) }
      .bind(to: output.navigation)
      .disposed(by: disposeBag)
    
    input.tappedRow
      .filter { $0.section == 0 }
      .map { _ -> (Navigation, Screen) in
        return (.replaceDrawerCenterInNav(animated: true), .currentAccount(GymRats.currentAccount))
      }
      .bind(to: output.navigation)
      .disposed(by: disposeBag)

    input.tappedRow
      .filter { $0.section == 1 }
      .withLatestFrom(challenges, resultSelector: { ($0, $1) })
      .map { stuff -> (Navigation, Screen) in
        let (indexPath, challenges) = stuff
        
        if challenges.isEmpty {
          return (.replaceDrawerCenterInNav(animated: true), .home)
        } else {
          let challenge = challenges[indexPath.row]
          
          UserDefaults.standard.set(challenge.id, forKey: "last_opened_challenge")

          if challenge.isActive {
            return (.replaceDrawerCenter(animated: true), .activeChallenge(challenge))
          } else {
            return (.replaceDrawerCenterInNav(animated: true), .upcomingChallenge(challenge))
          }
        }
      }
      .bind(to: output.navigation)
      .disposed(by: disposeBag)

    input.tappedRow
      .filter { $0.section == 2 }
      .compactMap { indexPath -> (Navigation, Screen)? in
        switch indexPath.row {
        case 0: return (.replaceDrawerCenterInNav(animated: true), .completedChallenges)
        case 1: return nil
        case 2: return (.presentInNav(animated: true), .createChallenge(self))
        case 3: return (.replaceDrawerCenterInNav(animated: true), .settings)
        case 4: return (.replaceDrawerCenterInNav(animated: true), .about)
        default: fatalError("Unhandled row")
        }
      }
      .bind(to: output.navigation)
      .disposed(by: disposeBag)

  }
}

extension MenuViewModel: CreateChallengeDelegate {
  func challengeCreated(challenge: Challenge) {
    Challenge.State.all.fetch().ignore(disposedBy: disposeBag)
    UserDefaults.standard.set(challenge.id, forKey: "last_opened_challenge")
    
    if challenge.isActive {
      output.navigation.on(.next((.replaceDrawerCenter(animated: true), .activeChallenge(challenge))))
    } else {
      output.navigation.on(.next((.replaceDrawerCenterInNav(animated: true), .upcomingChallenge(challenge))))
    }
  }
}
