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
    guard challenges.isNotEmpty else { return (.replaceDrawerCenterInNav(animated: false), .noChallenges) }

    let unseenCompletedChallenges = challenges.unseenCompletedChallenges()
    let activeOrUpcoming = challenges.getActiveAndUpcomingChallenges()
    let completed = challenges.getPastChallenges()

    defer { unseenCompletedChallenges.witness() }
    
    if activeOrUpcoming.isNotEmpty {
      if unseenCompletedChallenges.isNotEmpty {
        UserDefaults.standard.set(0, forKey: "last_opened_challenge")
      }
       
      ChallengeFlow.present(completedChallenges: unseenCompletedChallenges)
      
      return lastOpened(challenges)
    }
    
    let lastCompleted = completed.sorted { $0.endDate > $1.endDate }.first!
  
    Challenge.State.see(lastCompleted)
    ChallengeFlow.present(completedChallenges: unseenCompletedChallenges.filter { $0.id != lastCompleted.id })
    
    return (.replaceDrawerCenterInNav(animated: false), .completedChallenge(lastCompleted))
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
      return (.replaceDrawerCenterInNav(animated: false), .completedChallenge(challenge))
    }
  }
}
