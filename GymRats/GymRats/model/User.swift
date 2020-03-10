//
//  User.swift
//  GymRats
//
//  Created by Mack Hasz on 2/4/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation
import MessageKit

struct User: Codable, Hashable {
    let id: Int
    let email: String
    let fullName: String
    let profilePictureUrl: String?
    let token: String?
    let workouts: [Workout]?
  
    var hashValue: Int { return id }
}

extension User: AvatarProtocol {
    
    var myName: String? {
        return self.fullName
    }
    
    var pictureUrl: String? {
        return profilePictureUrl
    }
    
}

extension User {
    
    var asSender: Sender {
        return Sender(id: "\(id)", displayName: fullName)
    }
    
}
