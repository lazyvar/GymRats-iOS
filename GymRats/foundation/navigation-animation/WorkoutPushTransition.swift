//
//  WorkoutPushTransition.swift
//  GymRats
//
//  Created by mack on 8/4/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class WorkoutPushTransition: NSObject, UIViewControllerAnimatedTransitioning {
  private let from: ChallengeViewController
  private let to: WorkoutViewController
  private var shapeLayer: CAShapeLayer?
  
  private let transitionImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    
    return imageView
  }()

  init(from: ChallengeViewController, to: WorkoutViewController) {
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
      transitionImageView.frame = to.bigFrame
      toView.alpha = 1
      self.shapeLayer?.removeFromSuperlayer()
      transitionImageView.round(corners: [.topLeft, .topRight], radius: 4)
    }

    toView.alpha = 0
    transitionImageView.kf.setImage(with: from.selectedWorkoutPhotoURL, options: [.transition(.fade(0.2))])
    
    containerView.addSubview(fromView)
    containerView.addSubview(toView)
    containerView.addSubview(transitionImageView)

    transitionImageView.frame = from.selectedImageViewFrame
    shapeLayer = transitionImageView.round(corners: [.bottomLeft, .topLeft], radius: 4)
    
    from.transitionWillStart(push: true)
    to.transitionWillStart(push: true)
    from.tabBarController?.setTabBar(hidden: true)
    
    animator.addCompletion { [unowned transitionImageView, unowned from, unowned to] position in
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        transitionImageView.alpha = 0
        transitionImageView.removeFromSuperview()
        transitionImageView.image = nil
      }

      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
      to.hidesBottomBarWhenPushed = true
      from.transitionDidEnd(push: true)
      to.transitionDidEnd(push: true)
    }

    animator.startAnimation()
  }
}
