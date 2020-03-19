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
  func request(method: HTTPMethod, url: String, headers: HTTPHeaders, parameters: Parameters?) -> Observable<(HTTPURLResponse, Data)>
}

class ProductionNetworkProvider: NetworkProvider {
    
  private let baseUrl: String = "https://www.gymratsapi.com"
  
  func buildUrl(forPath path: String) -> String {
    return "\(baseUrl)/\(path)"
  }
  
  func request(method: HTTPMethod, url: String, headers: HTTPHeaders, parameters: Parameters?) -> Observable<(HTTPURLResponse, Data)> {
    let request: DataRequest
    
    if let parameters = parameters {
      request = Alamofire.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
    } else {
      request = Alamofire.request(url, method: method, parameters: parameters, headers: headers)
    }
    
    request.validate(statusCode: 200..<300)
    request.validate(contentType: ["application/json"])
    
    return request.rx.responseData()
  }
}

class PreProductionNetworkProvider: NetworkProvider {
  private let baseUrl: String = "https://gym-rats-api-pre-production.gigalixirapp.com"
  
  func buildUrl(forPath path: String) -> String {
    return "\(baseUrl)/\(path)"
  }
  
  func request(method: HTTPMethod, url: String, headers: HTTPHeaders, parameters: Parameters?) -> Observable<(HTTPURLResponse, Data)> {
    let request: DataRequest
    
    if let parameters = parameters {
      request = Alamofire.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
    } else {
      request = Alamofire.request(url, method: method, parameters: parameters, headers: headers)
    }
    
    request.validate(statusCode: 200..<300)
    request.validate(contentType: ["application/json"])
    
    return request.rx.responseData()
  }
}

class DevelopmentNetworkProvider: NetworkProvider {
  private let baseUrl: String = "http://localhost:4000"
  
  func buildUrl(forPath path: String) -> String {
    return "\(baseUrl)/\(path)"
  }

  func request(method: HTTPMethod, url: String, headers: HTTPHeaders, parameters: Parameters?) -> Observable<(HTTPURLResponse, Data)> {
    let request: DataRequest
    
    if let parameters = parameters {
      request = Alamofire.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
    } else {
      request = Alamofire.request(url, method: method, parameters: parameters, headers: headers)
    }

    return request.rx.responseData()
  }
}
