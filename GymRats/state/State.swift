//
//  State.swift
//  GymRats
//
//  Created by mack on 3/12/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import RxSwift

extension Challenge {
  enum State {
    static let all = Resource<NetworkResult<[Challenge]>> {
      return gymRatsAPI.getAllChallenges().do(onNext: { result in
        if let challenges = result.object {
          LocalNotificationService.synchronize(challenges: challenges)
          challenges.getActiveAndUpcomingChallenges().forEach { challenge in
            Challenge.State.join(challenge)
          }
        }
      })
    }
    
    static func join(_ challenge: Challenge) { UserDefaults.standard.set(true, forKey: "joined_challenge_\(challenge.id)") }
    static func joined(_ challenge: Challenge) -> Bool { UserDefaults.standard.bool(forKey:  "joined_challenge_\(challenge.id)") }
    static func see(_ challenge: Challenge) { UserDefaults.standard.set(true, forKey: "saw_challenge_\(challenge.id)") }
    static func saw(_ challenge: Challenge) -> Bool { UserDefaults.standard.bool(forKey:  "saw_challenge_\(challenge.id)") }
  }
}

extension Membership {
  enum State {
    private static let disposeBag = DisposeBag()
    private static var all: [Int: Bool] = [:]
  
    static func fetch(for challenge: Challenge) {
      guard all[challenge.id] == nil else { return }
      
      gymRatsAPI.getMembership(for: challenge)
        .subscribe(onNext: { result in
          if let membership = result.object {
            all[challenge.id] = membership.owner
          }
        })
        .disposed(by: disposeBag)
    }
    
    static func owner(of challenge: Challenge) -> Bool {
      return all[challenge.id] ?? true
    }
    
    static func clear() { all = [:] }
  }
}
