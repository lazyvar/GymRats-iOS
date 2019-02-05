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
    case login(_ email: String, _ password: String)
    case signup
    
    var requestProperties: (method: HTTPMethod, path: String, params: Parameters) {
        switch self {
        case .login(let email, let password):
            return (.post, "login", ["email": email, "password": password])
        case .signup:
            return (.post, "signup", [:])
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
    
    private func request<T: Decodable>(_ apiRequest: APIRequest) -> Observable<T> {
        return baseRequest(apiRequest).decodeObject()
    }
    
    private func request<T: Decodable>(_ apiRequest: APIRequest) -> Observable<[T]> {
        return baseRequest(apiRequest).decodeArray()
    }
    
    func login(email: String, password: String) -> Observable<User> {
        return request(.login(email, password))
            .do(onNext: { user in
                // set user in cache
                print("woo")
            })
    }
    
}
