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
  let workoutNotificationsEnabled: Bool?
  let commentNotificationsEnabled: Bool?
  let chatMessageNotificationsEnabled: Bool?
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

extension Account {
  static let dummy = Account(id: 0, email: "", fullName: "", profilePictureUrl: "", token: "", workoutNotificationsEnabled: nil, commentNotificationsEnabled: nil, chatMessageNotificationsEnabled: nil)

  static func loadCurrent() -> Account? {
    switch Keychain.gymRats.retrieveObject(forKey: .currentUser) {
    case .success(let account):
      Keychain.gymRats.deleteObject(withKey: .currentUser)
      saveCurrent(account)
      
      return account
    case .error:
      return UserDefaults.standard.codable(forKey: "gym_rats_account")
    }
  }
  
  static func saveCurrent(_ account: Account) {
    UserDefaults.standard.setCodable(account, forKey: "gym_rats_account")
  }
  
  static func removeCurrent() {
    UserDefaults.standard.removeObject(forKey: "gym_rats_account")
  }
}

extension Account: Avatar {
  var avatarName: String? { return fullName }
  var avatarImageURL: String? { return profilePictureUrl }
}

extension Account: SenderType {
  var senderId: String { return "\(id)" }
  var displayName: String { return fullName }
}
