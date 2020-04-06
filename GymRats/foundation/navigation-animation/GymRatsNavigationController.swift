//
//  GymRatsswift
//  GymRats
//
//  Created by mack on 4/6/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class GymRatsNavigationController: UINavigationController {
  private let coordinator = NavigationTransitionCoordinator()
  
  private lazy var edgeSwipeGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipe(_:))).apply {
    $0.edges = .left
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    delegate = coordinator

    view.addGestureRecognizer(edgeSwipeGestureRecognizer)
    view.backgroundColor = UIColor.background
    
    navigationBar.tintColor = .primaryText
    navigationBar.barTintColor = .background
    navigationBar.backgroundColor = .background
    navigationBar.isTranslucent = false
    navigationBar.setBackgroundImage(UIImage(color: .background), for: .default)
    navigationBar.shadowImage = UIImage()
    navigationBar.prefersLargeTitles = true
    navigationBar.largeTitleTextAttributes = [
      NSAttributedString.Key.font: UIFont.h1Bold,
      NSAttributedString.Key.foregroundColor: UIColor.primaryText
    ]
  }
  
  @objc private func handleSwipe(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
    guard let gestureRecognizerView = gestureRecognizer.view else { coordinator.interactionController = nil; return }
    
    let percent = gestureRecognizer.translation(in: gestureRecognizerView).x / gestureRecognizerView.bounds.size.width

    switch gestureRecognizer.state {
    case .began:
      coordinator.interactionController = UIPercentDrivenInteractiveTransition()
      popViewController(animated: true)
    case .changed:
      coordinator.interactionController?.update(percent)
    case .ended:
      if percent > 0.5 && gestureRecognizer.state != .cancelled {
        coordinator.interactionController?.finish()
      } else {
        coordinator.interactionController?.cancel()
      }
    
      coordinator.interactionController = nil
    default: break
    }
  }
}
