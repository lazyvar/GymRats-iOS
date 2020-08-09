//
//  Track.swift
//  GymRats
//
//  Created by mack on 1/4/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import Firebase

typealias JSON = [String: Any]

enum Track {
  enum Event: String {
    case login
    case signup
    case profileEdited = "profile_edited"
    case workoutLogged = "workout_logged"
    case passwordReset = "password_reset"
    case challengeEdited = "challenge_edited"
    case storeReviewRequested = "store_review_requested"
    case smsInviteSent = "sms_invite_sent"
    case challengeCreated = "challenge_created"
    case chatSent = "chat_sent"
    case commentedOnWorkout = "commented_on_workout"
    case sharedChallenge = "shared_challenge"
  }
    
  static func event(_ event: Event, parameters: JSON? = nil) {
    Analytics.logEvent(event.rawValue, parameters: parameters)
  }
    
  static func currentUser() {
    guard let currentUser = GymRats.currentAccount else { return }
    
    Analytics.setUserID(String(currentUser.id))
    Analytics.setUserProperty(currentUser.email, forName: "email")
    Analytics.setUserProperty(currentUser.fullName, forName: "name")
    
    let mode: String? = {
      if #available(iOS 12.0, *) {
        switch UIViewController().traitCollection.userInterfaceStyle {
        case .dark:
          return "dark"
        case .light:
          return "light"
        case .unspecified:
          return "unspecified"
        }
      } else {
        return nil
      }
    }()
    
    if let mode = mode {
      Analytics.setUserProperty(mode, forName: "interface_style")
    }
  }
}
