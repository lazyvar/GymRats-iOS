//
//  Account.swift
//  GymRats
//
//  Created by Mack Hasz on 2/4/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation
import MessageKit

struct Account: Codable, Hashable {
  let id: Int
  let email: String
  let fullName: String
  let profilePictureUrl: String?
  let token: String?

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

extension Account {
  static func loadCurrent() -> Account? {
    switch Keychain.gymRats.retrieveObject(forKey: .currentUser) {
    case .success(let user): return user
    case .error: return nil
    }
  }
  
  static func saveCurrent(_ account: Account) {
    Keychain.gymRats.storeObject(account, forKey: .currentUser)
  }
}

extension Account: AvatarProtocol {
  var myName: String? {
    return self.fullName
  }
  
  var pictureUrl: String? {
    return profilePictureUrl
  }
}

extension Account {
  var asSender: Sender {
    return Sender(id: "\(id)", displayName: fullName)
  }
}
