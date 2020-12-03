//
//  Colors.swift
//  GymRats
//
//  Created by Mack Hasz on 2/4/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

extension UIColor {
  static let brand: UIColor = .hex("#D33A2C")
  static let warning: UIColor = .hex("#FFCC00")
  static let niceBlue: UIColor = .hex("#1074E7")
  static let shadow: UIColor = .hex("#000000", alpha: 0.05)
  static let goodGreen: UIColor = .hex("#6DD400")

  static var divider: UIColor {
    switch UIDevice.contentMode {
    case .light: return .hex("#000000", alpha: 0.1)
    case .dark: return .hex("#FFFFFF", alpha: 0.1)
    }
  }

  static var primaryText: UIColor {
    switch UIDevice.contentMode {
    case .light: return .hex("#000000", alpha: 0.85)
    case .dark: return .white
    }
  }

  static var secondaryText: UIColor {
    switch UIDevice.contentMode {
    case .light: return .hex("#000000", alpha: 0.25)
    case .dark:
      if #available(iOS 13.0, *) {
        return .placeholderText
      } else {
        return .hex("#EAEAF5", alpha: 0.3)
      }
    }
  }

  static var background: UIColor {
    switch UIDevice.contentMode {
    case .light: return .hex("#F8F8F8")
    case .dark: return .black
    }
  }

  static var foreground: UIColor {
    switch UIDevice.contentMode {
    case .light: return .hex("#FFFFFF")
    case .dark:  return .hex("#262629")
    }
  }
}
