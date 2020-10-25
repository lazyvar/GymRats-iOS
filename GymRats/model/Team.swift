//
//  Team.swift
//  GymRats
//
//  Created by mack on 10/7/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation

struct Team: Codable, Equatable {
  let id: Int
  let name: String
  let photoUrl: String?
  let members: [Account]?
}

extension Team: Avatar {
  var avatarName: String? { return name }
  var avatarImageURL: String? { return photoUrl }
}
