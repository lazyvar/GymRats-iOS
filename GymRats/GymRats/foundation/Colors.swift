//
//  Colors.swift
//  GymRats
//
//  Created by Mack Hasz on 2/4/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

extension UIColor {
    static let brand: UIColor = .hex("#59ABE3")
    static let brandDark: UIColor = .hex("#4682b4")
    static let whiteSmoke: UIColor = .hex("#f5f5f5")
    static let fog: UIColor = .hex("#9B9B9B")
    static let firebrick: UIColor = .hex("#b22222")
    static let charcoal: UIColor = .hex("#4A4A4A")
}

extension UIImage {
    static let brand = UIImage(color: .brand)
    static let whiteSmoke = UIImage(color: .whiteSmoke)
    static let charcoal = UIImage(color: .charcoal)
    static let fog = UIImage(color: .fog)
    static let firebrick = UIImage(color: .firebrick)
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
