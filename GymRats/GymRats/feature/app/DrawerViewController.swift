//
//  DrawerViewController.swift
//  GymRats
//
//  Created by mack on 3/11/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import MMDrawerController

class DrawerViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
  
    let menu = MenuViewController()
    let home = HomeViewController().inNav()
    let drawer = MMDrawerController(center: home, leftDrawerViewController: menu).apply {
      $0.view.backgroundColor = .background
      $0.showsShadow = false
      $0.maximumLeftDrawerWidth = MenuViewController.menuWidth
      $0.centerHiddenInteractionMode = .full
      $0.openDrawerGestureModeMask = [.all]
      $0.closeDrawerGestureModeMask = [.all]
      $0.setDrawerVisualStateBlock(MMDrawerVisualState.parallaxVisualStateBlock(withParallaxFactor: 2))
    }
    
    install(drawer)
  }
}
