//
//  Navigation.swift
//  GymRats
//
//  Created by mack on 3/12/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

enum Navigation {
  case push(animated: Bool)
  case present(animated: Bool)
  case install
  case replaceDrawerCenter(animated: Bool)
  case replaceNav(animated: Bool)
}

extension UIViewController {
  func navigate(_ navigation: Navigation, to viewController: UIViewController) {
    switch navigation {
    case .push(animated: let animated):
      push(viewController, animated: animated)
    case .present(animated: let animated):
      present(viewController, animated: animated, completion: nil)
    case .install:
      install(viewController)
    case .replaceDrawerCenter(animated: let animated):
      mm_drawerController.setCenterView(viewController, withCloseAnimation: animated, completion: nil)
    case .replaceNav(animated: let animated):
      navigationController?.setViewControllers([viewController], animated: animated)
    }
  }
}
