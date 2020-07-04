//
//  API.swift
//  GymRats
//
//  Created by Mack Hasz on 2/4/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift
import RxAlamofire

enum APIRequest {
  case login(email: String, password: String)
  case signup(email: String, password: String, profilePictureUrl: String?, fullName: String)
  case resetPassword(email: String)
  case getAllChallenges
  case getCurrentAccount
  case getCompletedChallenges
  case joinChallenge(code: String)
  case createChallenge(startDate: Date, endDate: Date, name: String, bannerURL: String?, description: String?, scoreBy: ScoreBy)
  case getWorkoutsForChallenge(challenge: Challenge, page: Int)
  case getAllWorkouts(challenge: Challenge)
  case getAllWorkoutsForUser(user: Account)
  case getWorkouts(forUser: Account, inChallenge: Challenge)
  case postWorkout(_ workout: NewWorkout, photoURL: String?, challenges: [Int])
  case updateUser(email: String?, name: String?, password: String?, profilePictureUrl: String?, currentPassword: String?)
  case deleteWorkout(_ workout: Workout)
  case getCommentsForWorkout(_ workout: Workout)
  case postComment(comment: String, workout: Workout)
  case getChatMessages(_ challenge: Challenge, page: Int)
  case getChatNotificationCount(_ challenge: Challenge)
  case registerDevice(deviceToken: String)
  case getChallenge(id: Int)
  case getWorkout(id: Int)
  case deleteDevice
  case seeChatNotifications(Challenge)
  case leaveChallenge(_ challenge: Challenge)
  case editChallenge(_ challenge: UpdateChallenge)
  case deleteComment(id: Int)
  case changeBanner(challenge: Challenge, imageURL: String?)
  case getMembersForChallenge(_ challenge: Challenge)
  case challengeInfo(challenge: Challenge)
  case getChallengeForCode(code: String)
  case getMembership(challenge: Challenge)
  case updateNotificationSettings(workouts: Bool?, comments: Bool?, chatMessages: Bool?)
  
  var requestProperties: (method: HTTPMethod, path: String, params: Parameters?) {
    switch self {
    case .login(let email, let password):
      return (.post, "tokens", ["email": email, "password": password])
    case .signup(email: let email, password: let password, profilePictureUrl: let url, fullName: let fullName):
      var params: Parameters =  [
        "email": email,
        "password": password,
        "full_name": fullName
      ]
      
      if let url = url {
        params["profile_picture_url"] = url
      }

      return (.post, "accounts", params)
    case .resetPassword(let email):
      return (.post, "passwords", ["email": email])
    case .getAllChallenges:
      return (.get, "challenges", nil)
    case .getChallengeForCode(let code):
      return (.get, "challenges?code=\(code)", nil)
    case .getCompletedChallenges:
      return (.get, "challenges?filter=complete", nil)
    case .joinChallenge(let code):
      return (.post, "memberships", ["code": code])
    case .deleteComment(id: let id):
      return (.delete, "comments/\(id)", nil)
    case .createChallenge(let startDate, let endDate, let name, let bannerURL, let description, let scoreBy):
      var params: Parameters =  [
        "start_date": startDate.toISO(),
        "end_date": endDate.toISO(),
        "name": name,
        "time_zone": TimeZone.current.abbreviation()!,
        "score_by": scoreBy.rawValue
      ]
      
      if let bannerURL = bannerURL {
        params["profile_picture_url"] = bannerURL
      }
      
      if let description = description {
        params["description"] = description
      }
      
      return (.post, "challenges", params)
    case .editChallenge(let challenge):
      var params: Parameters =  [
        "start_date": challenge.startDate.toISO(),
        "end_date": challenge.endDate.toISO(),
        "name": challenge.name,
        "score_by": challenge.scoreBy.rawValue
      ]
      
      if let photoUrl = challenge.banner {
        params["profile_picture_url"] = photoUrl
      }
      
      if let description = challenge.description {
        params["description"] = description
      }
      
      return (.put, "challenges/\(challenge.id)", params)
    case .changeBanner(let challenge, let imageURL):
      let params: Parameters = [
        "profile_picture_url": imageURL
      ]
      
      return (.put, "challenges/\(challenge.id)", params)
    case .getAllWorkouts(challenge: let challenge):
      return (.get, "challenges/\(challenge.id)/workouts", nil)
    case .getWorkoutsForChallenge(challenge: let challenge, page: let page):
      return (.get, "challenges/\(challenge.id)/workouts?page=\(page)", nil)
    case .getAllWorkoutsForUser(user: let account):
      return (.get, "accounts/\(account.id)/workouts", nil)
    case .getChallenge(id: let id):
      return (.get, "challenges/\(id)", nil)
    case .getWorkout(id: let id):
      return (.get, "workouts/\(id)", nil)
    case .getWorkouts(forUser: let user, inChallenge: let challenge):
      return (.get, "challenges/\(challenge.id)/members/\(user.id)/workouts", nil)
    case .getMembersForChallenge(let challenge):
      return (.get, "challenges/\(challenge.id)/members", nil)
    case .getCurrentAccount:
      return (.get, "account", nil)
    case .postWorkout(let workout, let photo, let challenges):
      var params: Parameters = [
        "title": workout.title,
        "challenges": challenges,
      ]
      
      if let description = workout.description {
        params["description"] = description
      }

      if let photo = photo {
        params["photo_url"] = photo
      }

      if let googlePlaceId = workout.googlePlaceId {
        params["google_place_id"] = googlePlaceId
      }

      if let duration = workout.duration {
        params["duration"] = duration
      }

      if let distance = workout.distance {
        params["distance"] = distance
      }

      if let steps = workout.steps {
        params["steps"] = steps
      }

      if let calories = workout.calories {
        params["calories"] = calories
      }

      if let points = workout.points {
        params["points"] = points
      }
      
      if let appleDeviceName = workout.appleDeviceName {
        params["apple_device_name"] = appleDeviceName
      }
      
      if let appleSourceName = workout.appleSourceName {
        params["apple_source_name"] = appleSourceName
      }
      
      if let appleWorkoutUuid = workout.appleWorkoutUuid {
        params["apple_workout_uuid"] = appleWorkoutUuid
      }
      
      if let activityType = workout.activityType {
        params["activity_type"] = activityType.rawValue
      }

      return (.post, "workouts", params)
    case .updateUser(let email, let name, let password, let profilePictureUrl, let currentPassword):
      var params: Parameters = [:]
      
      if let email = email {
        params["email"] = email
      }
      
      if let password = password {
        params["password"] = password
      }
      
      if let currentPassword = currentPassword {
        params["current_password"] = currentPassword
      }

      if let profilePictureUrl = profilePictureUrl {
        params["profile_picture_url"] = profilePictureUrl
      }

      if let fullName = name {
        params["full_name"] = fullName
      }

      return (.put, "account", params)
    case .deleteWorkout(let workout):
      return (.delete, "workouts/\(workout.id)", nil)
    case .getCommentsForWorkout(let workout):
      return (.get, "workouts/\(workout.id)/comments", nil)
    case .postComment(comment: let comment, workout: let workout):
      let params: Parameters = [
        "content": comment,
      ]
      
      return (.post, "workouts/\(workout.id)/comments", params)
    case .getChatMessages(let challenge, page: let page):
      return (.get, "challenges/\(challenge.id)/messages?page=\(page)", nil)
    case .getChatNotificationCount(let challenge):
      return (.get, "challenges/\(challenge.id)/chat_notifications/count", nil)
    case .seeChatNotifications(let challenge):
      return (.post, "challenges/\(challenge.id)/chat_notifications/seen", nil)
    case .registerDevice(deviceToken: let deviceToken):
      let params: Parameters = [
        "token": deviceToken
      ]
        
      return (.post, "devices", params)
    case .deleteDevice:
      return (.delete, "devices", nil)
    case .leaveChallenge(let challenge):
      return (.delete, "memberships/\(challenge.id)", nil)
    case .getMembership(let challenge):
      return (.get, "memberships/\(challenge.id)", nil)
    case .challengeInfo(challenge: let challenge):
      return (.get, "challenges/\(challenge.id)/info", nil)
    case .updateNotificationSettings(let workouts, let comments, let chatMessages):
      var params: Parameters = [:]

      if let workouts = workouts {
        params["workout_notifications_enabled"] = workouts
      }

      if let comments = comments {
        params["comment_notifications_enabled"] = comments
      }
      
      if let chatMessages = chatMessages {
        params["chat_message_notifications_enabled"] = chatMessages
      }
      
      return (.put, "account", params)
    }
  }
}


struct EmptyJSON: Codable { }
