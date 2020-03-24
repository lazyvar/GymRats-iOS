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
    static let newWhite: UIColor = UIColor.init(red: 242.0/256.0, green: 242.0/256.0, blue: 247.0/256.0, alpha: 1.0)
    
    static var primaryText: UIColor {
       if #available(iOS 13.0, *) {
            return .label
        } else {
            return .black
        }
    }

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

    static var background: UIColor {
        if #available(iOS 13.0, *) {
            return .systemGray6
        } else {
            return UIColor.init(red: 242.0/256.0, green: 242.0/256.0, blue: 247.0/256.0, alpha: 1.0)
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
    
    static var shadow: UIColor {
        if #available(iOS 13.0, *) {
            if UIViewController().traitCollection.userInterfaceStyle == .dark {
                return UIColor.black.withAlphaComponent(0.7)
            } else {
                return UIColor.gray.withAlphaComponent(0.7)
            }
        } else {
            return UIColor.gray.withAlphaComponent(0.7)
        }
    }
}

extension UIImage {
    static let brand = UIImage(color: .brand)
    static let primaryText = UIImage(color: .primaryText)
}

extension UIColor {
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static func hex(_ hex: String) -> UIColor {
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
            alpha: 1
        )
    }
    
}


extension UIImage {
    
    public convenience init(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        
        color.setFill()
        UIRectFill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        
        self.init(cgImage: image.cgImage!)
    }
}
