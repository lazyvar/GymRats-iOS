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
    let userId: Int
    let title: String
    let description: String?
    let pictureUrl: String?
    let googleLocationId: String?
    let date: Date
}
