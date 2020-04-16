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
    static let all = Resource<NetworkResult<[Challenge]>> { gymRatsAPI.getAllChallenges() }
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
