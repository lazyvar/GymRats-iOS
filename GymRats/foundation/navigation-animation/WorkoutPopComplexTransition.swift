//
//  WorkoutPopTransition.swift
//  GymRats
//
//  Created by mack on 8/5/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import UIKit

public class WorkoutPopComplexTransition: NSObject {
  private let from: WorkoutViewController
  private let to: ChallengeViewController
  private var backgroundAnimation: UIViewPropertyAnimator? = nil
  private var transitionContext: UIViewControllerContextTransitioning? = nil
  
  private let transitionImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = 1

    return imageView
  }()

  init(from: WorkoutViewController, to: ChallengeViewController) {
    self.from = from
    self.to = to
  }

  func didPanWith(gesture: UIPanGestureRecognizer, view: UIView) {
    switch gesture.state {
    case .began, .possible:
      break
    case .cancelled, .failed, .ended:
      let velocity: CGPoint = gesture.velocity(in: view)
      let verticalVelocityIsStrong = abs(velocity.y) > 750
      
      completeTransition(didCancel: !verticalVelocityIsStrong || velocity.y < 0)
    case .changed:
      let translation = gesture.translation(in: nil)
      let translationVertical = translation.y
      let percentageComplete = self.percentageComplete(forVerticalDrag: translationVertical)
      
      transitionContext?.updateInteractiveTransition(percentageComplete)
      backgroundAnimation?.fractionComplete = percentageComplete
    @unknown default:
      break
    }
  }

  private func completeTransition(didCancel: Bool) {
    self.backgroundAnimation?.isReversed = didCancel

    let transitionContext = self.transitionContext!
    let backgroundAnimation = self.backgroundAnimation!
    
    let completionDuration: Double
    let completionDamping: CGFloat
    
    if didCancel {
      completionDuration = 0.45
      completionDamping = 0.75
    } else {
      completionDuration = 0.37
      completionDamping = 0.90
    }

    if didCancel {
      transitionContext.cancelInteractiveTransition()
    } else {
      transitionContext.finishInteractiveTransition()
    }

    backgroundAnimation.addCompletion { [weak self] (position) in
      transitionContext.completeTransition(!didCancel)
      self?.from.isInteractivelyDismissing = false
      self?.transitionContext = nil
    }

    if !didCancel {
      transitionContext.containerView.addSubview(transitionImageView)
      
      if let url = from.workout.photoUrl, let earl = URL(string: url) {
        transitionImageView.kf.setImage(with: earl, options: [.transition(.fade(0.2))])
      }

      let imageViewCell = from.view.allSubviews().first(ofType: ImageViewCell.self)!
      let frame = imageViewCell.superview?.convert(imageViewCell.frame, to: nil) ?? .zero
      
      transitionImageView.frame = frame
      self.from.view.alpha = 0

      let foregroundAnimation = UIViewPropertyAnimator(duration: completionDuration, dampingRatio: completionDamping) {
        self.transitionImageView.frame = self.to.selectedImageViewFrame
      }

      foregroundAnimation.addCompletion { _ in
        self.transitionImageView.alpha = 0
        self.transitionImageView.removeFromSuperview()
        self.transitionImageView.image = nil
      }
      
      foregroundAnimation.startAnimation()
    }
    
    let durationFactor = CGFloat(completionDuration / backgroundAnimation.duration)
    
    backgroundAnimation.continueAnimation(withTimingParameters: nil, durationFactor: durationFactor)
  }
  
  private func percentageComplete(forVerticalDrag verticalDrag: CGFloat) -> CGFloat {
    let maximumDelta = CGFloat(500)
    
    return CGFloat.scaleAndShift(value: verticalDrag, inRange: (min: CGFloat(0), max: maximumDelta))
  }
}

extension WorkoutPopComplexTransition: UIViewControllerAnimatedTransitioning {
  public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.3
  }

  public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    fatalError()
  }
}

extension WorkoutPopComplexTransition: UIViewControllerInteractiveTransitioning {
  public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
    self.transitionContext = transitionContext

    let containerView = transitionContext.containerView

    guard
      let fromView = transitionContext.view(forKey: .from),
      let toView = transitionContext.view(forKey: .to)
    else {
      return
    }

    from.transitionController = self

    containerView.addSubview(toView)
    containerView.addSubview(fromView)

    fromView.backgroundColor = .clear
    from.ugh.backgroundColor = .clear
    toView.alpha = 0
    
    let animation = UIViewPropertyAnimator(duration: 1, dampingRatio: 1, animations: {
      toView.alpha = 1
    })

    backgroundAnimation = animation
    self.to.tabBarController?.setTabBar(hidden: false, animated: true, alongside: animation)
  }
}
