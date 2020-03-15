//
//  ServiceResponse.swift
//  GymRats
//
//  Created by Mack Hasz on 2/11/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation

struct ServiceResponse<T: Decodable>: Decodable {
  let status: Status
  let data: T?
  let error: String?

  enum Status: String, Decodable {
    case success
    case failure
  }
}
