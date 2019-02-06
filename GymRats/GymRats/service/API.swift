//
//  API.swift
//  GymRats
//
//  Created by Mack Hasz on 2/4/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation

import Foundation
import Alamofire
import RxSwift
import RxAlamofire

let gymRatsAPI = GymRatsAPI()

enum APIRequest {
    case login(email: String, password: String)
    case signup
    case getAllChallenges
    case joinChallenge(code: String)
    case createChallenge(startDate: Date, endDate: Date, challengeName: String)
    case getUsersForChallenge(challenge: Challenge)
    case getWorkoutsForChallenge(challenge: Challenge)
    
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
        case .createChallenge(startDate: let startDate, endDate: let endDate, challengeName: let challengeName):
            return (.post, "challenge", [
                "startDate": startDate,
                "endDate": endDate,
                "challengeName": challengeName
            ])
        case .getUsersForChallenge(challenge: let challenge):
            return (.get, "challenge/\(challenge.id)/user", [:])
        case .getWorkoutsForChallenge(challenge: let challenge):
            return (.get, "challenge/\(challenge.id)/workout", [:])
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
    
    func createChallenge(startDate: Date, endDate: Date, challengeName: String) -> Observable<Challenge> {
        return requestObject(.createChallenge(startDate: startDate, endDate: endDate, challengeName: challengeName))
    }
    
    func getUsers(for challenge:  Challenge) -> Observable<[User]> {
        return requestArray(.getUsersForChallenge(challenge: challenge))
    }
    
    func getWorkouts(for challenge: Challenge) -> Observable<[Workout]> {
        return requestArray(.getWorkoutsForChallenge(challenge: challenge))
    }
    
}
