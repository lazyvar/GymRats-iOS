//
//  UIImage+Assets.swift
//  GymRats
//
//  Created by mack on 3/11/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

extension UIImage {
  static let moreHorizontal     = UIImage(named: "more-horizontal")!
  static let chat               = UIImage(named: "chat")!
  static let chatUnread         = UIImage(named: "chat-unread")!
  static let award              = UIImage(named: "award")!
  static let activityLargeWhite = UIImage(named: "activity-large-white")!
  static let activity           = UIImage(named: "activity")!
  static let flag               = UIImage(named: "flag")!
  static let plusCircle         = UIImage(named: "plus-circle")!
  static let play               = UIImage(named: "play")!
  static let gear               = UIImage(named: "gear")!
  static let info               = UIImage(named: "info")!
  static let chevronLeft        = UIImage(named: "chevron-left")!
  static let eyeOn              = UIImage(named: "eye-on")!
  static let eyeOff             = UIImage(named: "eye-off")!
  static let nameLight          = UIImage(named: "name-light")!
  static let checkLight         = UIImage(named: "check-light")!
  static let mailLight          = UIImage(named: "mail-light")!
  static let lockLight          = UIImage(named: "lock-light")!
  static let nameDark           = UIImage(named: "name-dark")!
  static let checkDark          = UIImage(named: "check-dark")!
  static let mailDark           = UIImage(named: "mail-dark")!
  static let lockDark           = UIImage(named: "lock-dark")!
  static let proPic             = UIImage(named: "pro-pic")!
  static let camera             = UIImage(named: "camera")!
  static let close              = UIImage(named: "close")!
  static let menu               = UIImage(named: "menu")!
  static let big                = UIImage(named: "big")!
  static let list               = UIImage(named: "list")!
  static let clock              = UIImage(named: "clock")!
  static let plus               = UIImage(named: "plus")!
  static let code               = UIImage(named: "code")!
  static let people             = UIImage(named: "people")!
  static let clipboard          = UIImage(named: "clipboard")!
  static let star               = UIImage(named: "star")!
  static let pencil             = UIImage(named: "pencil")!
  static let cal                = UIImage(named: "cal")!
  static let smallAppleHealth   = UIImage(named: "small-apple-health")!
  static let map                = UIImage(named: "map")!
  static let image              = UIImage(named: "image")!
  static let help               = UIImage(named: "help")!
  static let messenger          = UIImage(named: "messenger")!
  static let mailTemplate       = UIImage(named: "mail-template")!
  static let link               = UIImage(named: "link")!

  static var name: UIImage {
    switch UIDevice.contentMode {
    case .light: return .nameLight
    case .dark: return .nameDark
    }
  }

  static var check: UIImage {
    switch UIDevice.contentMode {
    case .light: return .checkLight
    case .dark: return .checkDark
    }
  }

  static var mail: UIImage {
    switch UIDevice.contentMode {
    case .light: return .mailLight
    case .dark: return .mailDark
    }
  }

  static var lock: UIImage {
    switch UIDevice.contentMode {
    case .light: return .lockLight
    case .dark: return .lockDark
    }
  }
}
