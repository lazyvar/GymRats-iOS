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
  static let niceBlue: UIColor = .hex("#1074E7")
  
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
  
  static var shadow: UIColor {
    switch UIDevice.contentMode {
    case .light: return .hex("#000000", alpha: 0.1)
    case .dark:  return .hex("#000000", alpha: 0.7)
    }
  }
  
  @available(*, deprecated, message: "Wtf is this.")
  static let newWhite: UIColor = UIColor.init(red: 242.0/256.0, green: 242.0/256.0, blue: 247.0/256.0, alpha: 1.0)

  static var secondaryLblColor: UIColor {
     if #available(iOS 13.0, *) {
         if UIViewController().traitCollection.userInterfaceStyle == .dark {
             return .systemGray2
         } else {
             return .systemGray4
         }
     } else {
        return UIColor(red: 188/255, green: 188/256, blue: 192/256, alpha: 1.0)
     }
  }

  static var chevron: UIColor {
     if #available(iOS 13.0, *) {
         if UIViewController().traitCollection.userInterfaceStyle == .dark {
             return .systemGray
         } else {
             return .systemGray5
         }
     } else {
      return UIColor(red: 216/255, green: 216/256, blue: 220/256, alpha: 1.0)
     }
  }

    static var foreground: UIColor {
        if #available(iOS 13.0, *) {
            if UIViewController().traitCollection.userInterfaceStyle == .dark {
                return .systemGray5
            } else {
                return .white
            }
        } else {
            return .white
        }
    }
    
}
