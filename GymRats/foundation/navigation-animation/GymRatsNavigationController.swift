//
//  GymRatsNavigationController.swift
//  GymRats
//
//  Created by mack on 4/6/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import GradientLoadingBar

class GymRatsNavigationController: UINavigationController, UINavigationBarDelegate {
  private enum Config {
    static let height: CGFloat = 3
  }

  private let wtf = UIView().apply {
    $0.frame = .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIApplication.shared.statusBarFrame.height)
    $0.backgroundColor = .background
    $0.layer.zPosition = .greatestFiniteMagnitude
  }

  private let gradientProgressIndicatorView = GradientActivityIndicatorView()
  private var currentAnimationTransition: UIViewControllerAnimatedTransitioning? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .background
    
    navigationBar.backgroundColor = .background
    navigationBar.tintColor = .primaryText
    navigationBar.barTintColor = .background
    navigationBar.isTranslucent = false
    navigationBar.shadowImage = UIImage()
    navigationBar.prefersLargeTitles = true
    
    navigationBar.largeTitleTextAttributes = [
      NSAttributedString.Key.font: UIFont.title,
      NSAttributedString.Key.foregroundColor: UIColor.primaryText
    ]
    
    navigationBar.titleTextAttributes = [
      NSAttributedString.Key.font: UIFont.h4,
      NSAttributedString.Key.foregroundColor: UIColor.primaryText
    ]
    
    gradientProgressIndicatorView.gradientColors = [UIColor.brand, UIColor.brand.withAlphaComponent(0.15), UIColor.brand.withAlphaComponent(0.45), UIColor.brand.withAlphaComponent(0.75)]
    gradientProgressIndicatorView.translatesAutoresizingMaskIntoConstraints = false
    
    navigationBar.addSubview(gradientProgressIndicatorView)

    NSLayoutConstraint.activate([
      gradientProgressIndicatorView.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor),
      gradientProgressIndicatorView.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor),
      gradientProgressIndicatorView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor),
      gradientProgressIndicatorView.heightAnchor.constraint(equalToConstant: Config.height)
    ])
    
    gradientProgressIndicatorView.fadeOut(duration: 0, completion: nil)
  }
  
  func showLoading() {
    gradientProgressIndicatorView.fadeIn()
  }
  
  func hideLoading() {
    gradientProgressIndicatorView.fadeOut()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if presentingViewController == nil && wtf.superview == nil {
      view.addSubview(wtf)
    }
  }
  
  func position(for bar: UIBarPositioning) -> UIBarPosition {
    return .topAttached
  }
}

extension GymRatsNavigationController: UINavigationControllerDelegate {
  public func navigationController(
    _ navigationController: UINavigationController,
    animationControllerFor operation: UINavigationController.Operation,
    from fromVC: UIViewController,
    to toVC: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    let transition: UIViewControllerAnimatedTransitioning? = {
      if
        let challengeViewController = fromVC as? ChallengeViewController,
        let workoutViewController = toVC as? WorkoutViewController,
        operation == .push {
          workoutViewController.pushedForFun = true
        
          return WorkoutPushTransition(from: challengeViewController, to: workoutViewController)
        }

      if
        let workoutViewController = fromVC as? WorkoutViewController,
        let challengeViewController = toVC as? ChallengeViewController,
        operation == .pop {
          if workoutViewController.isInteractivelyDismissing {
            return WorkoutPopComplexTransition(from: workoutViewController, to: challengeViewController)
          } else {
            return WorkoutPopSimpleTransition(from: workoutViewController, to: challengeViewController)
          }
        }
      
      return nil
    }()

    currentAnimationTransition = transition
    
    return currentAnimationTransition
  }
  
  public func navigationController(
    _ navigationController: UINavigationController,
    interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
  ) -> UIViewControllerInteractiveTransitioning? {
    return self.currentAnimationTransition as? UIViewControllerInteractiveTransitioning
  }

  public func navigationController(
    _ navigationController: UINavigationController,
    didShow viewController: UIViewController,
    animated: Bool
  ) {
    self.currentAnimationTransition = nil
  }
}
