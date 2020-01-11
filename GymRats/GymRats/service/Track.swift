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
    }
    
    static func event(_ event: Event, parameters: JSON? = nil) {
        Analytics.logEvent(event.rawValue, parameters: parameters)
    }
    
    static func currentUser() {
        guard let currentUser = GymRatsApp.coordinator.currentUser else { return }
        
        Analytics.setUserID(String(currentUser.id))
        Analytics.setUserProperty(currentUser.email, forName: "email")
        Analytics.setUserProperty(currentUser.fullName, forName: "name")
    }
    
    static func screens() {
        Analytics.setScreenName("welcome", screenClass: "WelcomeViewController")
        Analytics.setScreenName("login", screenClass: "LoginViewController")
        Analytics.setScreenName("signup", screenClass: "SignUpViewController")
        Analytics.setScreenName("settings", screenClass: "SettingsViewController")
        Analytics.setScreenName("challenge", screenClass: "ArtistViewController")
        Analytics.setScreenName("create_workout", screenClass: "NewWorkoutViewController")
        Analytics.setScreenName("challenge_stats", screenClass: "ChallengeStatsViewController")
        Analytics.setScreenName("workout_details", screenClass: "WorkoutViewController")
        Analytics.setScreenName("challenge_preview", screenClass: "UpcomingChallengeViewController")
        Analytics.setScreenName("create_challenge", screenClass: "CreateChallengeViewController")
        Analytics.setScreenName("profile", screenClass: "ProfileViewController")
        Analytics.setScreenName("chat", screenClass: "ChatViewController")
        Analytics.setScreenName("home", screenClass: "HomeViewController")
        Analytics.setScreenName("past_challenges", screenClass: "ArchivedChallengesTableViewController")
        Analytics.setScreenName("share_code", screenClass: "ShareCodeViewController")
        Analytics.setScreenName("about", screenClass: "AboutViewController")
        Analytics.setScreenName("edit_profile", screenClass: "ProfileChangeController")
        Analytics.setScreenName("change_password", screenClass: "ChangePasswordController")
    }
}
