//
//  UpdateChallenge.swift
//  GymRats
//
//  Created by mack on 3/10/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation

struct UpdateChallenge: Codable {
  let id: Int
  let name: String
  let code: String?
  let profilePictureUrl: String?
  let startDate: Date
  let endDate: Date
}
