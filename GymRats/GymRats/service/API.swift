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

let gymRatsAPI = GymRatsAPI()

enum APIRequest {
    case login(email: String, password: String)
    case signup
    case getAllChallenges
    case joinChallenge(code: String)
    case createChallenge(startDate: Date, endDate: Date, challengeName: String, photoUrl: String?)
    case getUsersForChallenge(challenge: Challenge)
    case getWorkoutsForChallenge(challenge: Challenge)
    case getWorkoutsForUser(user: User)
    case postWorkout(title: String, description: String?, photoUrl: String?, googlePlaceId: String?)
    
    var requestProperties: (method: HTTPMethod, path: String, params: Parameters) {
        switch self {
        case .login(let email, let password):
            return (.post, "login", ["email": email, "password": password])
        case .signup:
            return (.post, "signup", [:])
        case .getAllChallenges:
            return (.get, "challenge/all", [:])
        case .joinChallenge(let code):
            return (.post, "challenge/\(code)", [:])
        case .createChallenge(startDate: let startDate, endDate: let endDate, challengeName: let challengeName, photoUrl: let photoUrl):
            var params: Parameters =  [
                "startDate": startDate,
                "endDate": endDate,
                "challengeName": challengeName
            ]
            
            if let photoUrl = photoUrl {
                params["photoUrl"] = photoUrl
            }

            return (.post, "challenge", params)
        case .getUsersForChallenge(challenge: let challenge):
            return (.get, "challenge/\(challenge.id)/user", [:])
        case .getWorkoutsForChallenge(challenge: let challenge):
            return (.get, "challenge/\(challenge.id)/workout", [:])
        case .getWorkoutsForUser(user: let user):
            return (.get, "workout/user/\(user.id)", [:])
        case .postWorkout(title: let title, description: let description, photoUrl: let photoUrl, googlePlaceId: let googlePlaceId):
            var params: Parameters = ["title": title]
            
            if let description = description {
                params["desription"] = description
            }

            if let photoUrl = photoUrl {
                params["photoUrl"] = photoUrl
            }

            if let googlePlaceId = googlePlaceId {
                params["googlePlaceId"] = googlePlaceId
            }

            return (.get, "workout", params)
        }
    }
}

class GymRatsAPI {
    
    private let networkProvider: NetworkProvider
    
    init(networkProvider: NetworkProvider = MockedNetworkProvider()) {
        self.networkProvider = networkProvider
    }
    
    private func baseRequest(_ apiRequest: APIRequest) -> Observable<Data> {
        let (method, path, params) = apiRequest.requestProperties
        let url = networkProvider.buildUrl(forPath: path)
        
        return networkProvider.request(method: method, url: url, parameters: params)
                .map { $0.1 }
    }
    
    private func requestObject<T: Decodable>(_ apiRequest: APIRequest) -> Observable<T> {
        return baseRequest(apiRequest).decodeObject()
    }
    
    private func requestArray<T: Decodable>(_ apiRequest: APIRequest) -> Observable<[T]> {
        return baseRequest(apiRequest).decodeArray()
    }
    
    func login(email: String, password: String) -> Observable<User> {
        return requestObject(.login(email: email, password: password))
            .do(onNext: { user in
                // set user in cache
                // TODO
            })
    }
    
    func getAllChallenges() -> Observable<[Challenge]> {
        return requestArray(.getAllChallenges)
    }
    
    func joinChallenge(code: String) -> Observable<Challenge> {
        return requestObject(.joinChallenge(code: code))
    }
    
    func createChallenge(startDate: Date, endDate: Date, challengeName: String, photo: UIImage?) -> Observable<Challenge> {
        if let photo = photo {
            return ImageService.uploadImageToFirebase(image: photo)
                .flatMap { url in
                    return self.requestObject(.createChallenge(startDate: startDate, endDate: endDate, challengeName: challengeName, photoUrl: url))
                }
        } else {
            return requestObject(.createChallenge(startDate: startDate, endDate: endDate, challengeName: challengeName, photoUrl: nil))
        }
    }
    
    func getUsers(for challenge:  Challenge) -> Observable<[User]> {
        return requestArray(.getUsersForChallenge(challenge: challenge))
    }
    
    func getWorkouts(for challenge: Challenge) -> Observable<[Workout]> {
        return requestArray(.getWorkoutsForChallenge(challenge: challenge))
    }
    
    func getWorkouts(for user: User) -> Observable<[Workout]> {
        return requestArray(.getWorkoutsForUser(user: user))
    }

    func postWorkout(title: String, description: String?, photo: UIImage?, googlePlaceId: String?) -> Observable<Workout> {
        if let photo = photo {
            return ImageService.uploadImageToFirebase(image: photo)
                .flatMap { url in
                    return self.requestObject(.postWorkout(title: title, description: description, photoUrl: url, googlePlaceId: googlePlaceId))
                }
        } else {
            return requestObject(.postWorkout(title: title, description: description, photoUrl: nil, googlePlaceId: googlePlaceId))
        }
    }
    
}
