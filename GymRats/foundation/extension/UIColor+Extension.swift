//
//  UIColor+Extension.swift
//  GymRats
//
//  Created by mack on 4/6/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

extension UIColor {
  static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
    return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
  }
  
  static func hex(_ hex: String, alpha: CGFloat = 1) -> UIColor {
    let scanner = Scanner(string: hex)
    
    if hex[hex.startIndex] == "#" {
      scanner.scanLocation = 1  // skip #
    }
    
    var rgb: UInt32 = 0
    scanner.scanHexInt32(&rgb)
    
    return UIColor(
      red:   CGFloat((rgb & 0xFF0000) >> 16)/255.0,
      green: CGFloat((rgb &   0xFF00) >>  8)/255.0,
      blue:  CGFloat((rgb &     0xFF)      )/255.0,
      alpha: alpha
    )
  }
}
