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
    case signup(email: String, password: String, profilePictureUrl: String?, fullName: String)
    case getAllChallenges
    case joinChallenge(code: String)
    case createChallenge(startDate: Date, endDate: Date, challengeName: String, photoUrl: String?)
    case getUsersForChallenge(challenge: Challenge)
    case getWorkoutsForChallenge(challenge: Challenge)
    case getAllWorkoutsForUser(user: User)
    case getWorkouts(forUser: User, inChallenge: Challenge)
    case postWorkout(title: String, description: String?, photoUrl: String?, googlePlaceId: String?)
    case updateUser(email: String?, name: String?, password: String?, profilePictureUrl: String?)
        
    var requestProperties: (method: HTTPMethod, path: String, params: Parameters?) {
        switch self {
        case .login(let email, let password):
            return (.post, "login", ["email": email, "password": password])
        case .signup(email: let email, password: let password, profilePictureUrl: let url, fullName: let fullName):
            var params: Parameters =  [
                "email": email,
                "password": password,
                "full_name": fullName
            ]
            
            if let url = url {
                params["profile_picture_url"] = url
            }

            return (.post, "signup", params)
        case .getAllChallenges:
            return (.get, "challenge", nil)
        case .joinChallenge(let code):
            return (.post, "challenge/code/\(code)", nil)
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

            return (.post, "challenge", params)
        case .getUsersForChallenge(challenge: let challenge):
            return (.get, "challenge/\(challenge.id)/user", nil)
        case .getWorkoutsForChallenge(challenge: let challenge):
            return (.get, "challenge/\(challenge.id)/workout", nil)
        case .getAllWorkoutsForUser(user: let user):
            return (.get, "workout/user/\(user.id)", nil)
        case .getWorkouts(forUser: let user, inChallenge: let challenge):
            return (.get, "challenge/\(challenge.id)/workout/user/\(user.id)", nil)
        case .postWorkout(title: let title, description: let description, photoUrl: let photoUrl, googlePlaceId: let googlePlaceId):
            var params: Parameters = ["title": title]
            
            if let description = description {
                params["description"] = description
            }

            if let photoUrl = photoUrl {
                params["photo_url"] = photoUrl
            }

            if let googlePlaceId = googlePlaceId {
                params["google_place_id"] = googlePlaceId
            }

            return (.post, "workout", params)
        case .updateUser(email: let email, name: let name, password: let password, profilePictureUrl: let profilePictureUrl):
            var params: Parameters = [:]
            
            if let email = email {
                params["email"] = email
            }
            
            if let password = password {
                params["password"] = password
            }
            
            if let profilePictureUrl = profilePictureUrl {
                params["profile_picture_url"] = profilePictureUrl
            }

            if let name = name {
                params["full_name"] = name
            }

            return (.put, "user", params)
        }
    }
}

class GymRatsAPI {
    
    private let networkProvider: NetworkProvider
    
    init(networkProvider: NetworkProvider = DevelopmentNetworkProvider()) {
        self.networkProvider = networkProvider
    }
    
    private func baseRequest(_ apiRequest: APIRequest) -> Observable<Data> {
        let (method, path, params) = apiRequest.requestProperties
        let url = networkProvider.buildUrl(forPath: path)
        
        let headers: HTTPHeaders = {
            switch apiRequest {
            case .login, .signup:
                return [:]
            default:
                return ["Authorization": GymRatsApp.coordinator.currentUser.token!]
            }
        }()
        
        return networkProvider.request(method: method, url: url, headers: headers, parameters: params)
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
                switch Keychain.gymRats.storeObject(user, forKey: .currentUser) {
                case .success:
                    print("Woohoo!")
                case .error(let error):
                    print("Bummer! \(error.description)")
                }
            })
    }
    
    func signUp(email: String, password: String, profilePicture: UIImage?, fullName: String) -> Observable<User> {
        if let profilePicture = profilePicture {
            return ImageService.uploadImageToFirebase(image: profilePicture)
                .flatMap { url in
                    return self.requestObject(.signup(email: email, password: password, profilePictureUrl: url, fullName: fullName))
                        .do(onNext: { user in
                            switch Keychain.gymRats.storeObject(user, forKey: .currentUser) {
                            case .success:
                                print("Woohoo!")
                            case .error(let error):
                                print("Bummer! \(error.description)")
                            }
                        })
            }
        } else {
            return requestObject(.signup(email: email, password: password, profilePictureUrl: nil, fullName: fullName))
                .do(onNext: { user in
                    switch Keychain.gymRats.storeObject(user, forKey: .currentUser) {
                    case .success:
                        print("Woohoo!")
                    case .error(let error):
                        print("Bummer! \(error.description)")
                    }
                })
        }
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
    
    func getAllWorkouts(for user: User) -> Observable<[Workout]> {
        return requestArray(.getAllWorkoutsForUser(user: user))
    }

    func getWorkouts(for user: User, in challenge: Challenge) -> Observable<[Workout]> {
        return requestArray(.getWorkouts(forUser: user, inChallenge: challenge))
    }

    func postWorkout(title: String, description: String?, photo: UIImage?, googlePlaceId: String?) -> Observable<[Workout]> {
        if let photo = photo {
            return ImageService.uploadImageToFirebase(image: photo)
                .flatMap { url in
                    return self.requestObject(.postWorkout(title: title, description: description, photoUrl: url, googlePlaceId: googlePlaceId))
                }
        } else {
            return requestObject(.postWorkout(title: title, description: description, photoUrl: nil, googlePlaceId: googlePlaceId))
        }
    }
    
    func updateUser(email: String?, name: String?, password: String?, profilePicture: UIImage?) -> Observable<User> {
        if let profilePicture = profilePicture {
            return ImageService.uploadImageToFirebase(image: profilePicture)
                .flatMap { url in
                    return self.requestObject(.updateUser(email: email, name: name, password: password, profilePictureUrl: url))
            }
        } else {
            return self.requestObject(.updateUser(email: email, name: name, password: password, profilePictureUrl: nil))
        }
    }
    
}
