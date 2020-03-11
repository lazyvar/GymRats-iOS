//
//  GymRatsAPI.swift
//  GymRats
//
//  Created by mack on 3/10/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

class GymRatsAPI {
  private let networkProvider: NetworkProvider
  
  init(networkProvider: NetworkProvider = DevelopmentNetworkProvider()) {
    self.networkProvider = networkProvider
  }

  func login(email: String, password: String) -> Observable<NetworkResult<User>> {
    fatalError()
  }
  
  func signUp(email: String, password: String, profilePicture: UIImage?, fullName: String) -> Observable<NetworkResult<User>> {
    fatalError()
  }
  
  func resetPassword(email: String) -> Observable<NetworkResult<EmptyJSON>> {
    return requestObject(.resetPassword(email: email))
  }
  
  func getAllChallenges() -> Observable<NetworkResult<[Challenge]>> {
    return requestArray(.getAllChallenges)
  }

  func newGetAllChallenges() -> Observable<NetworkResult<[Challenge]>> {
    return requestArray(.getAllChallenges)
  }

  func joinChallenge(code: String) -> Observable<NetworkResult<Challenge>> {
    return requestObject(.joinChallenge(code: code))
  }
  
  func createChallenge(startDate: Date, endDate: Date, challengeName: String, photo: UIImage?) -> Observable<Challenge> {
    fatalError()
  }

  func editChallenge() -> Observable<Challenge> {
    fatalError()
  }

  func getUsers(for challenge:  Challenge) -> Observable<NetworkResult<[User]>> {
      return requestArray(.getUsersForChallenge(challenge: challenge))
  }
  
  func deleteComment(id: Int) -> Observable<NetworkResult<EmptyJSON>> {
      return requestObject(.deleteComment(id: id))
  }
  
  func getWorkouts(for challenge: Challenge) -> Observable<NetworkResult<[Workout]>> {
      return requestArray(.getWorkoutsForChallenge(challenge: challenge))
  }
  
  func getAllWorkouts(for user: User) -> Observable<NetworkResult<[Workout]>> {
      return requestArray(.getAllWorkoutsForUser(user: user))
  }

  func getWorkouts(for user: User, in challenge: Challenge) -> Observable<NetworkResult<[Workout]>> {
      return requestArray(.getWorkouts(forUser: user, inChallenge: challenge))
  }

  func postWorkout(_ workout: NewWorkout, challenges: [Challenge]) -> Observable<NetworkResult<[Workout]>> {
    return requestObject(.postWorkout(workout, challenges: challenges))
  }
  
  func updateUser(_ user: UpdateUser) -> Observable<NetworkResult<User>> {
    return requestObject(.updateUser(user))
  }
  
  func deleteWorkout(_ workout: Workout) -> Observable<NetworkResult<Workout>> {
    return requestObject(.deleteWorkout(workout))
  }
  
  func getComments(for workout: Workout) -> Observable<NetworkResult<[Comment]>> {
    return requestArray(.getCommentsForWorkout(workout))
  }
  
  func post(comment: String, on workout: Workout) -> Observable<NetworkResult<[Comment]>> {
    return requestArray(.postComment(comment: comment, workout: workout))
  }
  
  func getUnreadChats(for challenge: Challenge) -> Observable<NetworkResult<[ChatMessage]>> {
    return requestArray(.getUnreadChats(challenge))
  }
  
  func getAllChats(for challenge: Challenge, page: Int) -> Observable<NetworkResult<[ChatMessage]>> {
    return requestArray(.getChat(challenge, page: page))
  }
  
  func postChatMessage(_ message: String, for challenge: Challenge) -> Observable<NetworkResult<ChatMessage>> {
    return requestObject(.postChatMessage(message: message, challenge: challenge))
  }
  
  func registerDevice(deviceToken: String) -> Observable<NetworkResult<EmptyJSON>> {
    return requestObject(.registerDevice(deviceToken: deviceToken))
  }
  
  func deleteDevice() -> Observable<NetworkResult<String>> {
    return requestObject(.deleteDevice)
  }
  
  func leaveChallenge(_ challenge: Challenge) -> Observable<NetworkResult<Challenge>> {
    return requestObject(.leaveChallenge(challenge))
  }
}

extension GymRatsAPI {
  private func baseRequest(_ apiRequest: APIRequest) -> Observable<Data> {
    let (method, path, params) = apiRequest.requestProperties
    let url = networkProvider.buildUrl(forPath: path)
    
    let headers: HTTPHeaders = {
      switch apiRequest {
      case .login, .signup, .resetPassword:
        return [:]
      default:
        return ["Authorization": GymRats.currentAccount.token!]
      }
    }()
    
    return networkProvider
      .request(method: method, url: url, headers: headers, parameters: params)
      .map { $0.1 }
  }
  
  private func requestObject<T: Decodable>(_ apiRequest: APIRequest) -> Observable<NetworkResult<T>> {
    return baseRequest(apiRequest).decodeObject()
  }

  private func requestArray<T: Decodable>(_ apiRequest: APIRequest) -> Observable<NetworkResult<[T]>> {
    return baseRequest(apiRequest).decodeArray()
  }
}
