//
//  User.swift
//  GymRats
//
//  Created by Mack Hasz on 2/4/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation

struct User: Codable {
    let id: Int
    let email: String
    let fullName: String
    let profilePictureUrl: String?
    let token: String?
}

extension User: AvatarProtocol {
    
    var myName: String? {
        return self.fullName
    }
    
    var pictureUrl: String? {
        return profilePictureUrl
    }
    
}
