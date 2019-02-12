//
//  ServiceResponse.swift
//  GymRats
//
//  Created by Mack Hasz on 2/11/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation

struct ServiceResponse<T: Decodable>: Decodable {
    
    enum Status: String, Decodable {
        case success
        case failure
    }
    
    let status: Status
    let response: T?
    let errorMessage: String?
}

