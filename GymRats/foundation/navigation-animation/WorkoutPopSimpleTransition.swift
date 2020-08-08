//
//  WorkoutPopSimpleTransition.swift
//  GymRats
//
//  Created by mack on 8/8/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import UIKit

class WorkoutPopSimpleTransition: NSObject, UIViewControllerAnimatedTransitioning {
  private let from: WorkoutViewController
  private let to: ChallengeViewController

  private let transitionImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = 4

    return imageView
  }()

  init(from: WorkoutViewController, to: ChallengeViewController) {
    self.from = from
    self.to = to
  }

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.3
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let toView   = transitionContext.view(forKey: .to)!
    let fromView = transitionContext.view(forKey: .from)!
    let containerView = transitionContext.containerView
    let duration = transitionDuration(using: transitionContext)
    let spring: CGFloat = 1
    let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: spring) { [unowned transitionImageView, unowned to] in
      transitionImageView.frame = to.selectedImageViewFrame
      toView.alpha = 1
    }

    toView.alpha = 0

    if let url = from.workout.photoUrl, let earl = URL(string: url) {
      transitionImageView.kf.setImage(with: earl, options: [.transition(.fade(0.2))])
    }

    containerView.addSubview(fromView)
    containerView.addSubview(toView)
    containerView.addSubview(transitionImageView)

    transitionImageView.frame = from.bigFrame

    from.hidesBottomBarWhenPushed = false

    from.transitionWillStart(push: false)
    to.transitionWillStart(push: false)

    from.tabBarController?.setTabBar(hidden: false)

    animator.addCompletion { [unowned transitionImageView, unowned from, unowned to] position in
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
        transitionImageView.alpha = 0
        transitionImageView.removeFromSuperview()
        transitionImageView.image = nil
      }

      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)

      from.transitionDidEnd(push: false)
      to.transitionDidEnd(push: false)
    }

    animator.startAnimation()
  }
}
