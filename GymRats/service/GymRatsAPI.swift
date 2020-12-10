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
import YPImagePicker

let gymRatsAPI = GymRatsAPI()

class GymRatsAPI {
  private let networkProvider: NetworkProvider
  
  init(networkProvider: NetworkProvider = GymRats.environment.networkProvider) {
    self.networkProvider = networkProvider
  }

  func login(email: String, password: String) -> Observable<NetworkResult<Account>> {
    return requestObject(.login(email: email, password: password))
  }

  func signUp(email: String, password: String, profilePicture: UIImage?, fullName: String) -> Observable<NetworkResult<Account>> {
    return Observable<UIImage?>.just(profilePicture)
      .flatMap { image -> Observable<String?> in
        guard let image = image else { return .just(nil) }
      
        return StorageService.upload(image).map { url -> String? in url }
      }
      .flatMap { url in
        return self.requestObject(.signup(email: email, password: password, profilePictureUrl: url, fullName: fullName))
      }
  }
  
  func getCurrentAccount() -> Observable<NetworkResult<Account>> {
    return requestObject(.getCurrentAccount)
  }
  
  func resetPassword(email: String) -> Observable<NetworkResult<EmptyJSON>> {
    return requestObject(.resetPassword(email: email))
  }
  
  func getAllChallenges() -> Observable<NetworkResult<[Challenge]>> {
    return requestArray(.getAllChallenges)
  }

  func getCompletedChallenges() -> Observable<NetworkResult<[Challenge]>> {
    return requestArray(.getCompletedChallenges)
  }

  func createTeam(challenge: Challenge, name: String, photo: Either<UIImage, String>?) -> Observable<NetworkResult<Team>> {
    return Observable<Either<UIImage, String>?>.just(photo)
      .flatMap { image -> Observable<String?> in
        guard let image = image else { return .just(nil) }
      
        switch image {
        case .left(let image): return StorageService.upload(image).map { url -> String? in url }
        case .right(let url): return .just(url)
        }
      }
      .flatMap { url in
        return self.requestObject(.createTeam(challenge: challenge, name: name, photoUrl: url))
      }
  }
  
  func joinTeam(team: Team) -> Observable<NetworkResult<Team>> {
    return requestObject(.joinTeam(team: team))
  }
  
  func joinChallenge(code: String) -> Observable<NetworkResult<Challenge>> {
    return requestObject(.joinChallenge(code: code))
  }
  
  func fetchTeams(challenge: Challenge) -> Observable<NetworkResult<[Team]>> {
    return requestArray(.fetchTeams(challenge))
  }
  
  func teamStats(_ team: Team) -> Observable<NetworkResult<Stats>> {
    return requestObject(.teamStats(team))
  }

  func teamRankings(_ team: Team) -> Observable<NetworkResult<[Ranking]>> {
    return requestArray(.teamRankings(team))
  }

  func createChallenge(_ newChallenge: NewChallenge) -> Observable<NetworkResult<Challenge>> {
    return Observable<Either<UIImage, String>?>.just(newChallenge.banner)
      .flatMap { image -> Observable<String?> in
        guard let image = image else { return .just(nil) }
      
        switch image {
        case .left(let image): return StorageService.upload(image).map { url -> String? in url }
        case .right(let url): return .just(url)
        }
      }
      .flatMap { url in
        return self.requestObject(.createChallenge(startDate: newChallenge.startDate, endDate: newChallenge.endDate, name: newChallenge.name, bannerURL: url, description: newChallenge.description, scoreBy: newChallenge.scoreBy, teamsEnabled: newChallenge.teamsEnabled))
      }
  }

  func updateChallenge(_ challenge: UpdateChallenge) -> Observable<NetworkResult<Challenge>> {
    return self.requestObject(.editChallenge(challenge))
  }
  
  func changeBanner(challenge: Challenge, imageOrURL: Either<UIImage, String>?) -> Observable<NetworkResult<Challenge>> {
    return Observable<Either<UIImage, String>?>.just(imageOrURL)
      .flatMap { image -> Observable<String?> in
        guard let image = image else { return .just(nil) }
      
        switch image {
        case .left(let image): return StorageService.upload(image).map { url -> String? in url }
        case .right(let url): return .just(url)
        }
      }
      .flatMap { url in
        return self.requestObject(.changeBanner(challenge: challenge, imageURL: url))
      }
  }
  
  func getChallenge(id: Int) -> Observable<NetworkResult<Challenge>> {
    return requestObject(.getChallenge(id: id))
  }

  func getChallenge(code: String) -> Observable<NetworkResult<[Challenge]>> {
    return requestObject(.getChallengeForCode(code: code))
  }
  
  func getRankings(challenge: Challenge, scoreBy: ScoreBy) -> Observable<NetworkResult<[Ranking]>> {
    return requestArray(.getRankings(challenge, scoreBy: scoreBy))
  }
  
  func getTeamRankings(challenge: Challenge, scoreBy: ScoreBy) -> Observable<NetworkResult<[TeamRanking]>> {
    return requestArray(.getTeamRankings(challenge, scoreBy: scoreBy))
  }

  func getWorkout(id: Int) -> Observable<NetworkResult<Workout>> {
    return requestObject(.getWorkout(id: id))
  }

  func updateTeam(_ team: UpdateTeam) -> Observable<NetworkResult<Team>> {
    return Observable<Either<UIImage, String>?>.just(team.photo)
      .flatMap { image -> Observable<String?> in
        guard let image = image else { return .just(nil) }
      
        switch image {
        case .left(let image): return StorageService.upload(image).map { url -> String? in url }
        case .right(let url): return .just(url)
        }
      }
      .flatMap { url in
        return self.requestObject(.updateTeam(id: team.id, name: team.name, photoUrl: url))
      }
  }

  func deleteComment(id: Int) -> Observable<NetworkResult<EmptyJSON>> {
    return requestObject(.deleteComment(id: id))
  }
  
  func getWorkouts(for challenge: Challenge, page: Int) -> Observable<NetworkResult<[Workout]>> {
    return requestArray(.getWorkoutsForChallenge(challenge: challenge, page: page))
  }

  func getAllWorkouts(for challenge: Challenge) -> Observable<NetworkResult<[Workout]>> {
    return requestArray(.getAllWorkouts(challenge: challenge))
  }

  func getAllWorkouts(for user: Account) -> Observable<NetworkResult<[Workout]>> {
    return requestArray(.getAllWorkoutsForUser(user: user))
  }
  
  func getGroupStats(for challenge: Challenge) -> Observable<NetworkResult<GroupStats>> {
    return requestObject(.groupStats(challenge))
  }

  func getWorkouts(for user: Account, in challenge: Challenge) -> Observable<NetworkResult<[Workout]>> {
    return requestArray(.getWorkouts(forUser: user, inChallenge: challenge))
  }

  func postWorkout(_ workout: NewWorkout, challenges: [Int]) -> Observable<NetworkResult<Workout>> {
    let media: Observable<[NewWorkout.Medium]> = {
      switch workout.media {
      case .left(let mediaItems):
        return Observable<NewWorkout.Medium>.combineLatest(mediaItems.map { StorageService.upload(localMedium: $0) })
      case .right(let media):
        return Observable.just(media)
      }
    }()

    return media.flatMap { media in
      return self.requestObject(.postWorkout(workout, media: media, challenges: challenges))
    }
  }

  func update(_ workout: UpdateWorkout) -> Observable<NetworkResult<Workout>> {
    return self.requestObject(.updateWorkout(workout))
  }

  func getMembers(for challenge: Challenge) -> Observable<NetworkResult<[Account]>> {
    return requestArray(.getMembersForChallenge(challenge))
  }
  
  func getMembership(for challenge: Challenge) -> Observable<NetworkResult<Membership>> {
    return requestObject(.getMembership(challenge: challenge))
  }

  func teamMembership(_ team: Team) -> Observable<NetworkResult<EmptyJSON>> {
    return requestObject(.teamMembership(team))
  }

  func updateUser(email: String?, name: String?, password: String?, profilePicture: UIImage?, currentPassword: String?) -> Observable<NetworkResult<Account>> {
    return Observable<UIImage?>.just(profilePicture)
      .flatMap { image -> Observable<String?> in
        guard let image = image else { return .just(nil) }
      
        return StorageService.upload(image).map { url -> String? in url }
      }
      .flatMap { url in
        return self.requestObject(.updateUser(email: email, name: name, password: password, profilePictureUrl: url, currentPassword: currentPassword))
      }
  }
  
  func deleteWorkout(_ workout: Workout) -> Observable<NetworkResult<EmptyJSON>> {
    return requestObject(.deleteWorkout(workout))
  }
  
  func getComments(for workout: Workout) -> Observable<NetworkResult<[Comment]>> {
    return requestArray(.getCommentsForWorkout(workout))
  }
  
  func post(comment: String, on workout: Workout) -> Observable<NetworkResult<Comment>> {
    return requestObject(.postComment(comment: comment, workout: workout))
  }
  
  func getChatNotificationCount(for challenge: Challenge) -> Observable<NetworkResult<ChatNotificationCount>> {
    return requestObject(.getChatNotificationCount(challenge))
  }

  func seeChatNotifications(for challenge: Challenge) -> Observable<NetworkResult<String>> {
    return requestObject(.seeChatNotifications(challenge))
  }

  func getChatMessages(for challenge: Challenge, page: Int) -> Observable<NetworkResult<[ChatMessage]>> {
    return requestArray(.getChatMessages(challenge, page: page))
  }

  func registerDevice(deviceToken: String) -> Observable<NetworkResult<EmptyJSON>> {
    return requestObject(.registerDevice(deviceToken: deviceToken))
  }
  
  func updateNotificationSettings(workouts: Bool? = nil, comments: Bool? = nil, chatMessages: Bool? = nil) -> Observable<NetworkResult<Account>> {
    return requestObject(.updateNotificationSettings(workouts: workouts, comments: comments, chatMessages: chatMessages))
  }
  
  func deleteDevice() -> Observable<NetworkResult<String>> {
    return requestObject(.deleteDevice)
  }
  
  func leaveChallenge(_ challenge: Challenge) -> Observable<NetworkResult<Challenge>> {
    return requestObject(.leaveChallenge(challenge))
  }
  
  func leaveTeam(_ team: Team) -> Observable<NetworkResult<Team>> {
    return requestObject(.leaveTeam(team))
  }
  
  func challengeInfo(_ challenge: Challenge) -> Observable<NetworkResult<ChallengeInfo>> {
    return requestObject(.challengeInfo(challenge: challenge))
  }
}

extension GymRatsAPI {
  private func baseRequest(_ apiRequest: APIRequest) -> Observable<NetworkResult<Data>> {
    let (method, path, params) = apiRequest.requestProperties
    let url = networkProvider.buildUrl(forPath: path)
    
    let headers: HTTPHeaders = {
      switch apiRequest {
      case .login, .signup, .resetPassword:
        return [:]
      default:
        guard let token = GymRats.currentAccount?.token else { return [:] }
          
        return ["Authorization": token]
      }
    }()
    
    return networkProvider
      .request(method: method, url: url, headers: headers, parameters: params)
      .map { .success($0.1) }
      .catchError { error -> Observable<NetworkResult<Data>> in
//        Crashlytics.crashlytics().record(error: error) TODO
        
        return .just(.failure(error.localized()))
      }
  }
  
  private func requestObject<T: Decodable>(_ apiRequest: APIRequest) -> Observable<NetworkResult<T>> {
    return baseRequest(apiRequest).decodeObject()
  }

  private func requestArray<T: Decodable>(_ apiRequest: APIRequest) -> Observable<NetworkResult<[T]>> {
    return baseRequest(apiRequest).decodeArray()
  }
}
