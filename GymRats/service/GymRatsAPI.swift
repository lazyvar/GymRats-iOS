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

let gymRatsAPI = GymRatsAPI()

class GymRatsAPI {
  private let networkProvider: NetworkProvider
  
  init(networkProvider: NetworkProvider = DevelopmentNetworkProvider()) {
    self.networkProvider = networkProvider
  }

  func login(email: String, password: String) -> Observable<NetworkResult<Account>> {
    return requestObject(.login(email: email, password: password))
  }
  
  func signUp(email: String, password: String, profilePicture: UIImage?, fullName: String) -> Observable<NetworkResult<Account>> {
    return Observable<UIImage?>.just(profilePicture)
      .flatMap { image -> Observable<String?> in
        guard let image = image else { return .just(nil) }
      
        return ImageService.uploadImageToFirebase(image: image).map { url -> String? in url }
      }
      .flatMap { url in
        return self.requestObject(.signup(email: email, password: password, profilePictureUrl: url, fullName: fullName))
      }
  }
  
  func resetPassword(email: String) -> Observable<NetworkResult<EmptyJSON>> {
    return requestObject(.resetPassword(email: email))
  }
  
  func getAllChallenges() -> Observable<NetworkResult<[Challenge]>> {
    return requestArray(.getAllChallenges)
  }

  func joinChallenge(code: String) -> Observable<NetworkResult<Challenge>> {
    return requestObject(.joinChallenge(code: code))
  }
  
  func createChallenge(startDate: Date, endDate: Date, challengeName: String, photo: UIImage?) -> Observable<NetworkResult<Challenge>> {
    return Observable<UIImage?>.just(photo)
      .flatMap { image -> Observable<String?> in
        guard let image = image else { return .just(nil) }
      
        return ImageService.uploadImageToFirebase(image: image).map { url -> String? in url }
      }
      .flatMap { url in
        return self.requestObject(.createChallenge(startDate: startDate, endDate: endDate, challengeName: challengeName, photoUrl: url))
      }
  }

  func updateChallenge(id: Int, startDate: Date, endDate: Date, challengeName: String, photo: UIImage?) -> Observable<NetworkResult<Challenge>> {
    return Observable<UIImage?>.just(photo)
      .flatMap { image -> Observable<String?> in
        guard let image = image else { return .just(nil) }
      
        return ImageService.uploadImageToFirebase(image: image).map { url -> String? in url }
      }
      .flatMap { url in
        return self.requestObject(.editChallenge(UpdateChallenge(id: id, name: challengeName, profilePictureUrl: url, startDate: startDate, endDate: endDate)))
      }
  }

  func getUsers(for challenge:  Challenge) -> Observable<NetworkResult<[Account]>> {
    return requestArray(.getUsersForChallenge(challenge: challenge))
  }
  
  func getChallenge(id: Int) -> Observable<NetworkResult<Challenge>> {
    return requestObject(.getChallenge(id: id))
  }

  func getWorkout(id: Int) -> Observable<NetworkResult<Workout>> {
    return requestObject(.getWorkout(id: id))
  }

  func deleteComment(id: Int) -> Observable<NetworkResult<EmptyJSON>> {
    return requestObject(.deleteComment(id: id))
  }
  
  func getWorkouts(for challenge: Challenge) -> Observable<NetworkResult<[Workout]>> {
    return requestArray(.getWorkoutsForChallenge(challenge: challenge))
  }
  
  func getAllWorkouts(for user: Account) -> Observable<NetworkResult<[Workout]>> {
    return requestArray(.getAllWorkoutsForUser(user: user))
  }

  func getWorkouts(for user: Account, in challenge: Challenge) -> Observable<NetworkResult<[Workout]>> {
    return requestArray(.getWorkouts(forUser: user, inChallenge: challenge))
  }

  func postWorkout(_ workout: NewWorkout, challenges: [Int]) -> Observable<NetworkResult<Workout>> {
    return Observable<UIImage?>.just(workout.photo)
      .flatMap { image -> Observable<String?> in
        guard let image = image else { return .just(nil) }
      
        return ImageService.uploadImageToFirebase(image: image).map { url -> String? in url }
      }
      .flatMap { url in
        return self.requestObject(.postWorkout(workout, photoURL: url, challenges: challenges))
      }
  }
  
  func getMembers(for challenge: Challenge) -> Observable<NetworkResult<[Account]>> {
    return requestArray(.getMembersForChallenge(challenge))
  }
  
  func updateUser(_ user: UpdateUser) -> Observable<NetworkResult<Account>> {
    return requestObject(.updateUser(user))
  }
  
  func deleteWorkout(_ workout: Workout) -> Observable<NetworkResult<Workout>> {
    return requestObject(.deleteWorkout(workout))
  }
  
  func getComments(for workout: Workout) -> Observable<NetworkResult<[Comment]>> {
    return requestArray(.getCommentsForWorkout(workout))
  }
  
  func post(comment: String, on workout: Workout) -> Observable<NetworkResult<Comment>> {
    return requestObject(.postComment(comment: comment, workout: workout))
  }
  
  func getUnreadChats(for challenge: Challenge) -> Observable<NetworkResult<[ChatMessage]>> {
    return requestArray(.getUnreadChats(challenge))
  }
  
  func getChatMessages(for challenge: Challenge, page: Int) -> Observable<NetworkResult<[ChatMessage]>> {
    return requestArray(.getChatMessages(challenge, page: page))
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
