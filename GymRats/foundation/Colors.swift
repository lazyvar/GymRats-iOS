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
  static let divider: UIColor = .hex("#000000", alpha: 0.1)

  static var primaryText: UIColor {
    switch UIDevice.contentMode {
    case .light: return .hex("#000000", alpha: 0.85)
    case .dark:  return .hex("#FFFFFF")
    }
  }

  static var secondaryText: UIColor {
    switch UIDevice.contentMode {
    case .light: return .hex("#000000", alpha: 0.25)
    case .dark:  return .hex("#FFFFFF") // Dark mode todo
    }
  }

  static var background: UIColor {
    switch UIDevice.contentMode {
    case .light: return .hex("#FAFAFA")
    case .dark:  return .hex("#1C1E21")
    }
  }

  static var foreground: UIColor {
    switch UIDevice.contentMode {
    case .light: return .hex("#FFFFFF")
    case .dark:  return .hex("#2C2C2E")
    }
  }
}
