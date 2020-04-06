//
//  NavigationTransitionCoordinator.swift
//  GymRats
//
//  Created by mack on 4/6/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

final class NavigationTransitionCoordinator: NSObject, UINavigationControllerDelegate {
  var interactionController: UIPercentDrivenInteractiveTransition?

  func navigationController(
    _ navigationController: UINavigationController,
    animationControllerFor operation: UINavigationController.Operation,
    from fromVC: UIViewController,
    to toVC: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    switch operation {
    case .push:
      return NavigationTransitionAnimator(presenting: true)
    case .pop:
      return NavigationTransitionAnimator(presenting: false)
    default:
      return nil
    }
  }

  func navigationController(
    _ navigationController: UINavigationController,
    interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
  ) -> UIViewControllerInteractiveTransitioning? {
    return interactionController
  }
}
