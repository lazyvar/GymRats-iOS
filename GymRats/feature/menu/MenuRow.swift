//
//  MenuRow.swift
//  GymRats
//
//  Created by mack on 3/12/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

enum MenuRow {
  case profile(Account)
  case challenge(Challenge)
  case item(Item)
  case home
  
  enum Item {
    case completed
    case join
    case start
    case settings
    case about
  
    var title: String {
      switch self {
      case .completed: return "Completed"
      case .join: return "Join"
      case .start: return "Start"
      case .settings: return "Settings"
      case .about: return "About"
      }
    }

    var image: UIImage {
      switch self {
      case .completed: return .archive
      case .join: return .plusCircle
      case .start: return .play
      case .settings: return .gear
      case .about: return .info
      }
    }
  }
}
