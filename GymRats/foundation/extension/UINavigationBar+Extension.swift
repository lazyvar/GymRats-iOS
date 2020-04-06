//
//  UINavigationBar+Extension.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

extension UINavigationBar {
  func turnSolidWhiteSlightShadow() {
    isTranslucent = false
    setBackgroundImage(UIImage(color: .background), for: .default)
    shadowImage = UIImage()
  }
}
