//
//  RouteCalculator.swift
//  GymRats
//
//  Created by mack on 8/1/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation

enum RouteCalculator {
  static func home(_ challenges: [Challenge], presentUnseen: Bool = true) -> (Navigation, Screen) {
//    let c = challenges.first(where: { $0.name == "Climb Mount Everest" })!
//    
//    return (.replaceDrawerCenterInNav(animated: false), .shareChallenge(c))
    
    guard challenges.isNotEmpty else { return (.replaceDrawerCenterInNav(animated: false), .noChallenges) }
    
    let unseenCompletedChallenges = challenges.unseenCompletedChallenges()
    let activeOrUpcoming = challenges.getActiveAndUpcomingChallenges()
    
    if activeOrUpcoming.isNotEmpty {
      if presentUnseen && unseenCompletedChallenges.isNotEmpty {
        UserDefaults.standard.set(0, forKey: "last_opened_challenge")
      }
 
      if presentUnseen {
        ChallengeFlow.present(completedChallenges: unseenCompletedChallenges)
        unseenCompletedChallenges.witness()
      }
      
      return lastOpened(activeOrUpcoming)
    }
    
    if presentUnseen, let lastCompleted = unseenCompletedChallenges.sorted(by: { $0.endDate > $1.endDate }).first {
      unseenCompletedChallenges.witness()
      
      return (.replaceDrawerCenterInNav(animated: false), .completedChallenge(lastCompleted, itIsAParty: true))
    } else {
      return (.replaceDrawerCenterInNav(animated: false), .noChallenges)
    }
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
