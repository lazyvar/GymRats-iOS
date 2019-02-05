//
//  NetworkProvider.swift
//  GymRats
//
//  Created by Mack Hasz on 2/4/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation
import RxAlamofire
import RxSwift
import Alamofire

protocol NetworkProvider {
    func buildUrl(forPath path: String) -> String
    func request(method: HTTPMethod, url: String) -> Observable<(HTTPURLResponse, Data)>
}

class ProductionNetworkProvider: NetworkProvider {
    
    private let baseUrl: String = "https://api.gymrats.com"
    
    func buildUrl(forPath path: String) -> String {
        return "\(baseUrl)/\(path)"
    }
    
    func request(method: HTTPMethod, url: String) -> Observable<(HTTPURLResponse, Data)> {
        return RxAlamofire.request(method, url)
                .validate(statusCode: 200..<300)
                .validate(contentType: ["application/json"])
                .responseData()
    }
    
}

//class DevelopmentNetworkProvider: NetworkProvider {
//
//    func buildUrl(forPath path: String) -> String {
//
//    }
//
//    func request(method: HTTPMethod, url: String) -> Observable<HasHTTPResponse> {
//
//    }
//
//}

class MockedNetworkProvider: NetworkProvider {

    func buildUrl(forPath path: String) -> String {
        return path
    }

    func request(method: HTTPMethod, url: String) -> Observable<(HTTPURLResponse, Data)> {
        return Observable<(HTTPURLResponse, Data)>.create { subscriber in
            let data = self.mockedResponse(forURL: url)

            subscriber.onNext((.dummy, data))
            
            return Disposables.create()
        }.delay(1, scheduler: MainScheduler.instance)
    }
    
    private func mockedResponse(forURL url: String) -> Data {
        let json: String = {
            switch url {
            case "login":
                return "todo"
            case "signup":
                return "todo"
            default:
                return "path not mockec"
            }
        }()
        
        return json.data(using: .utf8)!
    }
    
}

extension HTTPURLResponse {
    
    static let dummy = HTTPURLResponse (
        url: URL(string: "https://www.google.com")!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
    )!
    
}
