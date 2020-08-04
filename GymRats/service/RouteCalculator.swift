//
//  RouteCalculator.swift
//  GymRats
//
//  Created by mack on 8/1/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation

enum RouteCalculator {
  static func home(_ challenges: [Challenge]) -> (Navigation, Screen) {
    let activeOrUpcoming = challenges.getActiveAndUpcomingChallenges()
    
    guard activeOrUpcoming.isNotEmpty else { return (.replaceDrawerCenterInNav(animated: false), .noChallenges) }
    
    return lastOpened(activeOrUpcoming)
  }
  
  private static func lastOpened(_ challenges: [Challenge]) -> (Navigation, Screen) {
    let challengeId = UserDefaults.standard.integer(forKey: "last_opened_challenge")
    let challenge = challenges.first { $0.id == challengeId } ?? challenges.first!
    
    switch challenge.status {
    case .active:
      return (.replaceDrawerCenter(animated: false), .activeChallenge(challenge))
    case .upcoming:
      return (.replaceDrawerCenterInNav(animated: false), .upcomingChallenge(challenge))
    case .complete:
      return (.replaceDrawerCenterInNav(animated: false), .completedChallenge(challenge, itIsAParty: true))
    }
  }
}
