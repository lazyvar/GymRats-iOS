//
//  User.swift
//  GymRats
//
//  Created by Mack Hasz on 2/4/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation

struct User: Codable {
    let id: String
    let email: String
    let fullName: String
    let proPicUrl: String?
    let token: String?
}
