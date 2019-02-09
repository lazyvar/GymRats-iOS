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
    let title: String
    let description: String?
    let photoUrl: String?
    let place: Place?
    let createdAt: Date
    
    struct Place: Codable {
        let name: String
        let latitude: Double
        let longitude: Double
    }
}
