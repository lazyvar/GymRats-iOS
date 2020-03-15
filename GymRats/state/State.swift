//
//  State.swift
//  GymRats
//
//  Created by mack on 3/12/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation

extension Challenge {
  enum State {
    static let all = Resource<NetworkResult<[Challenge]>> { gymRatsAPI.getAllChallenges() }
  }
}
