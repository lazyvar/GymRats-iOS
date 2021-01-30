//
//  GRFormViewController.swift
//  GymRats
//
//  Created by mack on 11/9/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation
import Eureka

class GRFormViewController: FormViewController {
  override var customNavigationAccessoryView: (UIView & NavigationAccessory)? {
    let navView = NavigationAccessoryView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44.0))
    navView.barTintColor = .foreground
    navView.tintColor = UIColor.brand

    return navView
  }
}
