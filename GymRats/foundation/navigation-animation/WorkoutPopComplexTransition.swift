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
    imageView.layer.cornerRadius = 4

    return imageView
  }()
  
  init(from: WorkoutViewController, to: ChallengeViewController) {
    self.from = from
    self.to = to
  }

  func didPanWith(gestureRecognizer: UIPanGestureRecognizer) {
    let transitionContext = self.transitionContext!
    let transitionImageView = self.transitionImageView
    let translation = gestureRecognizer.translation(in: nil)
    let translationVertical = translation.y
    let percentageComplete = self.percentageComplete(forVerticalDrag: translationVertical)
    let transitionImageScale = transitionImageScaleFor(percentageComplete: percentageComplete)

    switch gestureRecognizer.state {
    case .possible, .began:
      break
    case .cancelled, .failed:
      self.completeTransition(didCancel: true)
    case .changed:
      transitionImageView.transform = CGAffineTransform.identity
        .scaledBy(x: transitionImageScale, y: transitionImageScale)
        .translatedBy(x: translation.x, y: translation.y)

      transitionContext.updateInteractiveTransition(percentageComplete)
      self.backgroundAnimation?.fractionComplete = percentageComplete

    case .ended:
      let fingerIsMovingDownwards = gestureRecognizer.velocity(in: nil).y > 0
      let transitionMadeSignificantProgress = percentageComplete > 0.1
      let shouldComplete = fingerIsMovingDownwards && transitionMadeSignificantProgress
      self.completeTransition(didCancel: !shouldComplete)
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

    let foregroundAnimation = UIViewPropertyAnimator(duration: completionDuration, dampingRatio: completionDamping) {
      self.transitionImageView.transform = CGAffineTransform.identity
      self.transitionImageView.frame = didCancel
        ? self.from.bigFrame
        : self.to.selectedImageViewFrame
    }

    foregroundAnimation.addCompletion { [weak self] (position) in
      self?.transitionImageView.removeFromSuperview()
      self?.transitionImageView.image = nil
      self?.to.transitionDidEnd(push: false)
      self?.from.transitionDidEnd(push: false)

      if didCancel {
        transitionContext.cancelInteractiveTransition()
      } else {
        transitionContext.finishInteractiveTransition()
      }
      
      transitionContext.completeTransition(!didCancel)
      
      self?.transitionContext = nil
    }

    let durationFactor = CGFloat(foregroundAnimation.duration / backgroundAnimation.duration)
    backgroundAnimation.continueAnimation(withTimingParameters: nil, durationFactor: durationFactor)
    foregroundAnimation.startAnimation()
  }

  private func percentageComplete(forVerticalDrag verticalDrag: CGFloat) -> CGFloat {
    let maximumDelta = CGFloat(200)
    
    return CGFloat.scaleAndShift(value: verticalDrag, inRange: (min: CGFloat(0), max: maximumDelta))
  }

  func transitionImageScaleFor(percentageComplete: CGFloat) -> CGFloat {
    let minScale = CGFloat(0.68)
    let result = 1 - (1 - minScale) * percentageComplete
    
    return result
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

    from.transitionWillStart(push: false)
    to.transitionWillStart(push: false)

    containerView.addSubview(toView)
    containerView.addSubview(fromView)
    containerView.addSubview(transitionImageView)

    if let url = from.workout.photoUrl, let earl = URL(string: url) {
      transitionImageView.kf.setImage(with: earl, options: [.transition(.fade(0.2))])
    }
    
    transitionImageView.frame = from.bigFrame

    let animation = UIViewPropertyAnimator(duration: 1, dampingRatio: 1, animations: {
      fromView.alpha = 0
    })
    
    self.backgroundAnimation = animation
    
    //    toVC.locketTabBarController?.setTabBar(hidden: false, animated: true, alongside: animation)
  }
}
