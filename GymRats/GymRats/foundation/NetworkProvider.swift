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
    func request(method: HTTPMethod, url: String, parameters: Parameters) -> Observable<(HTTPURLResponse, Data)>
}

class ProductionNetworkProvider: NetworkProvider {
    
    private let baseUrl: String = "https://api.gymrats.com"
    
    func buildUrl(forPath path: String) -> String {
        return "\(baseUrl)/\(path)"
    }
    
    func request(method: HTTPMethod, url: String, parameters: Parameters) -> Observable<(HTTPURLResponse, Data)> {
        let request = Alamofire.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default)
        request.validate(statusCode: 200..<300)
        request.validate(contentType: ["application/json"])
        
        return request.rx.responseData()
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

    func request(method: HTTPMethod, url: String, parameters: Parameters) -> Observable<(HTTPURLResponse, Data)> {
        return Observable<(HTTPURLResponse, Data)>.create { subscriber in
            let data = self.mockedResponse(forURL: url, and: parameters)

            switch url {
            case "login":
                if parameters["email"] as! String == "error" {
                    subscriber.onError(NSError(domain: "Wrong combo.", code: 100, userInfo: nil))
                } else {
                    subscriber.onNext((.dummy, data))
                }
            default:
                subscriber.onNext((.dummy, data))
            }
            
            return Disposables.create()
        }.delay(1, scheduler: MainScheduler.instance)
    }
    
    private func mockedResponse(forURL url: String, and parameters: Parameters) -> Data {
        let json: String = {
            switch url {
            case "login":
                return """
                {
                    "id": 101,
                    "email": "mack@hasz.email",
                    "fullName": "Mack Hasz",
                    "proPicUrl": "https://s3.amazonaws.com/com.hasz.oh/profile/3312CA11-9241-4B80-A9A1-76CCAC8306E5.jpg",
                    "token": "eyJhbGciOiJIUzUxMiJ9.eyJpZCI6MTAxLCJ1c2VybmFtZSI6Im1hY2sifQ.bWylH53ljxUs9Adl-sNBCNyU7ONi9vOAp-tChlUsOH1IInzzeidoJ-OFZnZlMMTVaRDXFbKj2Wn5aCih3ves9w",
                }
                """
            case "signup":
                return "todo"
            case "group/all":
                switch GymRatsApp.delegate.appCoordinator.currentUser.email {
                case "no-active-groups":
                    return """
                    []
                    """
                case "single-active-groups":
                    return """
                    [{
                    "id": 101,
                    "name": "CapTech Rats",
                    "code": "123456",
                    "startDate": 1546300800,
                    "endDate": 1556668800
                    }]
                    """
                case "many-active-groups":
                    return """
                    [{
                    "id": 101,
                    "name": "CapTech Rats",
                    "code": "123456",
                    "startDate": 1546300800,
                    "endDate": 1556668800
                    },{
                    "id": 102,
                    "name": "Hasz Fam",
                    "code": "ABCDEF",
                    "startDate": 1546300800,
                    "endDate": 1556668800
                    }]
                    """
                default:
                    return """
                    [{
                    "id": 101,
                    "name": "CapTech Rats",
                    "code": "123456",
                    "startDate": 1546300800,
                    "endDate": 1556668800
                    }]
                    """
                }
            case "/group/123456":
                return """
                {
                "id": 101,
                "name": "CapTech Rats",
                "code": "123456",
                "startDate": 1546300800,
                "endDate": 1556668800
                }
                """
            case "/group":
                return """
                {
                "id": 101,
                "name": "CapTech Rats",
                "code": "123456",
                "startDate": 1546300800,
                "endDate": 1556668800
                }
                """
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
