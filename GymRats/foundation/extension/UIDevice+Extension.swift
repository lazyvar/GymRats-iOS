//
//  UIDevice+Extension.swift
//  GymRats
//
//  Created by mack on 4/6/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

extension UIDevice {
  enum ContentMode {
    case light
    case dark
  }
  
  static var contentMode: ContentMode {
    if #available(iOS 13.0, *) {
      if UIViewController().traitCollection.userInterfaceStyle == .dark {
        return .dark
      } else {
        return .light
      }
    } else {
      return .light
    }
  }
}
