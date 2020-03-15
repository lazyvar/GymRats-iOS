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
  case joinChallenge(code: String)
  case createChallenge(startDate: Date, endDate: Date, challengeName: String, photoUrl: String?)
  case getUsersForChallenge(challenge: Challenge)
  case getWorkoutsForChallenge(challenge: Challenge)
  case getAllWorkoutsForUser(user: Account)
  case getWorkouts(forUser: Account, inChallenge: Challenge)
  case postWorkout(_ workout: NewWorkout, photoURL: String?, challenges: [Int])
  case updateUser(_ user: UpdateUser)
  case deleteWorkout(_ workout: Workout)
  case getCommentsForWorkout(_ workout: Workout)
  case postComment(comment: String, workout: Workout)
  case getChatMessages(_ challenge: Challenge, page: Int)
  case postChatMessage(message: String, challenge: Challenge)
  case getUnreadChats(_ challenge: Challenge)
  case registerDevice(deviceToken: String)
  case deleteDevice
  case leaveChallenge(_ challenge: Challenge)
  case editChallenge(_ challenge: UpdateChallenge)
  case deleteComment(id: Int)
  case getMembersForChallenge(_ challenge: Challenge)
  
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
    case .joinChallenge(let code):
      return (.post, "memberships", ["code": code])
    case .deleteComment(id: let id):
      return (.delete, "comments/\(id)", nil)
    case .createChallenge(startDate: let startDate, endDate: let endDate, challengeName: let challengeName, photoUrl: let photoUrl):
      var params: Parameters =  [
        "start_date": startDate.toISO(),
        "end_date": endDate.toISO(),
        "name": challengeName,
        "time_zone": TimeZone.current.abbreviation()!
      ]
      
      if let photoUrl = photoUrl {
        params["profile_picture_url"] = photoUrl
      }
      
      return (.post, "challenges", params)
    case .editChallenge(let challenge):
      var params: Parameters =  [
        "start_date": challenge.startDate.toISO(),
        "end_date": challenge.endDate.toISO(),
        "name": challenge.name
      ]
      
      if let photoUrl = challenge.profilePictureUrl {
        params["profile_picture_url"] = photoUrl
      }
      
      return (.put, "challenges/\(challenge.id)", params)
    case .getUsersForChallenge(challenge: let challenge):
      return (.get, "challenges/\(challenge.id)/members", nil)
    case .getWorkoutsForChallenge(challenge: let challenge):
      return (.get, "challenges/\(challenge.id)/workouts", nil)
    case .getAllWorkoutsForUser(user: let user):
      return (.get, "workout/user/\(user.id)", nil)
    case .getWorkouts(forUser: let user, inChallenge: let challenge):
      return (.get, "challenges/\(challenge.id)/members/\(user.id)/workouts", nil)
    case .getMembersForChallenge(let challenge):
      return (.get, "/challenges/\(challenge.id)/members", nil)
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

      return (.post, "workouts", params)
    case .updateUser(let user):
      var params: Parameters = [:]
      
      if let email = user.email {
        params["email"] = email
      }
      
      if let password = user.password {
        params["password"] = password
      }
      
      if let profilePictureUrl = user.profilePictureUrl {
        params["profile_picture_url"] = user.profilePictureUrl
      }

      if let fullName = user.fullName {
        params["full_name"] = fullName
      }

      return (.put, "accounts/self", params)
    case .deleteWorkout(let workout):
      return (.delete, "workouts/\(workout.id)", nil)
    case .getCommentsForWorkout(let workout):
      return (.get, "workouts/\(workout.id)/comments", nil)
    case .postComment(comment: let comment, workout: let workout):
      let params: Parameters = [
          "content": comment,
      ]
      
      return (.post, "comments", params)
    case .getChatMessages(let challenge, page: let page):
      return (.get, "challenges/\(challenge.id)/messages?page=\(page)", nil)
    case .postChatMessage(message: let message, challenge: let challenge):
      let params: Parameters = [
          "content": message,
      ]
        
      return (.post, "deprecated", params)
    case .getUnreadChats(let challenge):
      return (.get, "deprecated", nil)
    case .registerDevice(deviceToken: let deviceToken):
      let params: Parameters = [
          "token": deviceToken
      ]
        
      return (.post, "devices", params)
    case .deleteDevice:
      return (.delete, "devices", nil)
    case .leaveChallenge(let challenge):
      return (.delete, "memberships/\(challenge.id)", nil)
    }
  }
}


struct EmptyJSON: Codable { }
