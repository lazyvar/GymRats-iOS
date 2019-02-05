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
    case getAllGroups
    case joinChallenge(code: String)
    case createChallenge(startDate: Date, endDate: Date, groupName: String)
    
    var requestProperties: (method: HTTPMethod, path: String, params: Parameters) {
        switch self {
        case .login(let email, let password):
            return (.post, "login", ["email": email, "password": password])
        case .signup:
            return (.post, "signup", [:])
        case .getAllGroups:
            return (.get, "group/all", [:])
        case .joinChallenge(let code):
            return (.post, "/group/\(code)", [:])
        case .createChallenge(startDate: let startDate, endDate: let endDate, groupName: let groupName):
            return (.post, "/group", [
                "startDate": startDate,
                "endDate": endDate,
                "groupName": groupName
            ])
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
                print("woo")
            })
    }
    
    func getAllGroups() -> Observable<[Group]> {
        return requestArray(.getAllGroups)
    }
    
    func joinChallenge(code: String) -> Observable<Group> {
        return requestObject(.joinChallenge(code: code))
    }
    
    func createGroup(startDate: Date, endDate: Date, groupName: String) -> Observable<Group> {
        return requestObject(.createChallenge(startDate: startDate, endDate: endDate, groupName: groupName))
    }
}
