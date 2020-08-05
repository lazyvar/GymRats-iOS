//
//  GymRatsswift
//  GymRats
//
//  Created by mack on 4/6/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class GymRatsNavigationController: UINavigationController, UINavigationBarDelegate {
  private let wtf = UIView().apply {
    $0.frame = .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIApplication.shared.statusBarFrame.height)
    $0.backgroundColor = .background
    $0.layer.zPosition = .greatestFiniteMagnitude
  }

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
    
    delegate = self
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
    guard
      let challengeViewController = fromVC as? ChallengeViewController,
      let workoutViewController = toVC as? WorkoutViewController,
      operation == .push else { return nil }
    
    return WorkoutPushTransition(from: challengeViewController, to: workoutViewController)
  }
}
