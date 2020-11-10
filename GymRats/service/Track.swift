//
//  Track.swift
//  GymRats
//
//  Created by mack on 1/4/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import Segment

typealias JSON = [String: Any]

enum Track {
  enum Event: String {
    case login
    case signup
    case profileEdited = "profile-edited"
    case workoutLogged = "workout-logged"
    case passwordReset = "password-reset"
    case challengeEdited = "challenge-edited"
    case storeReviewRequested = "store-review-requested"
    case challengeCreated = "challenge-created"
    case chatSent = "chat-sent"
    case commentedOnWorkout = "commented-on-workout"
    case sharedChallenge = "shared-challenge"
    case invitedToChallenge = "invited-to-challenge"
  }
  
  enum Screen: String {
    case welcome
    case login
    case signup
    case todaysGoal = "todays-goal"
    case challengePreview = "challenge-preview"
    case joinTeam = "join-team"
    case chooseChallengeMode = "choose-challenge-mode"
    case joinChallenge = "join-challenge"
    case createTeam = "create-team"
    case team
    case noChallenges = "no-challenges"
    case upcomingChallenge = "upcoming-challenge"
    case chat
    case profile
    case workout
    case challenge
    case challengeDetails = "challenge-details"
    case teamRankings = "team-rankings"
    case rankings
    case editChallenge = "edit-challenge"
    case editWorkout = "edit-workout"
    case editTeam = "edit-team"
    case createWorkout = "create-workout"
    case createCustomChallenge = "create-custom-challenge"
    case createClassicChallenge = "create-classic-challenge"
    case challengeBanner = "challenge-banner"
    case enableTeams = "enable-teams"
    case createFirstTeam = "create-first-team"
    case createChallengeReview = "create-challenge-review"
    case inviteToChallenge = "invite-to-challenge"
    case about
    case settings
    case notificationSettings = "notification-settings"
    case completedChallenges = "completed-challenges"
    case completedChallenge = "completed-challenge"
    case workoutList = "workout-list"
    case shareChallenge = "share-challenge"
  }

  static func event(_ event: Track.Event, properties: JSON? = nil) {
    GymRats.segment.track(event.rawValue, properties: properties)
  }

  static func screen(_ screen: Track.Screen, properties: JSON? = nil) {
    GymRats.segment.screen(screen.rawValue, properties: properties)
  }
}
