//
//  Workout.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation

struct Workout: Codable {
    let id: Int
    let gymRatsUserId: Int
    let challengeId: Int
    let title: String
    let description: String?
    let photoUrl: String?
    let createdAt: Date
    let googlePlaceId: String?
}

extension Workout: AvatarProtocol {
    
    var pictureUrl: String? {
        return photoUrl
    }
    
    var myName: String? {
        return title
    }
    
}
