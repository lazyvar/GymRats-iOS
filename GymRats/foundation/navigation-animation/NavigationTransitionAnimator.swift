//
//  NavigationTransitionAnimator.swift
//  GymRats
//
//  Created by mack on 4/6/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

final class NavigationTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  let presenting: Bool

  init(presenting: Bool) {
    self.presenting = presenting
  }

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return TimeInterval(UINavigationController.hideShowBarDuration)
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard let fromView = transitionContext.view(forKey: .from) else { return }
    guard let toView = transitionContext.view(forKey: .to) else { return }

    let duration = transitionDuration(using: transitionContext)
    let container = transitionContext.containerView
    
    if presenting {
      container.addSubview(toView)
    } else {
      container.insertSubview(toView, belowSubview: fromView)
    }

    let toViewFrame = toView.frame
    toView.frame = CGRect(
      x: presenting ? toView.frame.width : -100,
      y: toView.frame.origin.y,
      width: toView.frame.width,
      height: toView.frame.height
    )
    
    UIView.animate(
      withDuration: duration,
      delay: 0,
      options: .curveEaseOut,
      animations: {
        toView.frame = toViewFrame
        fromView.frame = CGRect(
          x: self.presenting ? -100 : fromView.frame.width,
          y: fromView.frame.origin.y,
          width: fromView.frame.width,
          height: fromView.frame.height
        )
      },
      completion: { _ in
        container.addSubview(toView)
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
      }
    )
  }
}
