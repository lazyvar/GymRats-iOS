//
//  ChallengeTabBarController.swift
//  GymRats
//
//  Created by mack on 3/11/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import ESTabBarController_swift
import RxSwift

class ChallengeTabBarController: ESTabBarController {

  // MARK: Init

  private let challenge: Challenge
  private let challengeViewController: ChallengeViewController
  private let disposeBag = DisposeBag()
  
  init(challenge: Challenge) {
    self.challenge = challenge
    self.challengeViewController = ChallengeViewController(challenge: challenge)
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    viewControllers = [
      UIViewController().apply {
        $0.tabBarItem = UITabBarItem(title: nil, image: .award, selectedImage: .award)
      },
      challengeViewController.inNav().apply {
        $0.tabBarItem = ESTabBarItem(BigContentView(), title: nil, image: .activityLargeWhite, selectedImage: .activityLargeWhite)
      },
      UIViewController().apply {
        $0.tabBarItem = UITabBarItem(title: nil, image: .chat, selectedImage: .chat)
        $0.tabBarItem?.badgeColor = .brand
      }
    ]
    
    NotificationCenter.default.addObserver(self, selector: #selector(updateChatIcon), name: .appEnteredForeground, object: nil)
    
    configureTabBar()
    selectedIndex = 1
    didHijackHandler = hijack
    shouldHijackHandler = { _, _, _ in return true }
    
    NotificationCenter.default.addObserver(self, selector: #selector(sawChat), name: .sawChat, object: nil)
  }
  
  private var chatItem: UITabBarItem? { return tabBar.items?[safe: 2] }
  
  @objc private func sawChat(notification: Notification) {
    guard let challenge = notification.object as? Challenge else { return }
    
    if challenge.id == self.challenge.id {
      chatItem?.badgeValue = nil
    }
  }
  
  @objc func updateChatIcon() {
    gymRatsAPI.getChatNotificationCount(for: challenge)
      .subscribe(onNext: { [weak self] result in
        let count = result.object?.count ?? 0
        
        if count == .zero {
          self?.chatItem?.badgeValue = nil
        } else {
          self?.chatItem?.badgeValue = String(count)
        }
      })
      .disposed(by: disposeBag)
  }
}

private extension ChallengeTabBarController {

  private func hijack(tabBar: UITabBarController, viewController: UIViewController, index: Int) {
    switch index {
    case 0: pushStats()
    case 1: presentCreateWorkout()
    case 2: pushChat()
    default: fatalError("Unexpected index.")
    }
  }
  
  private func pushStats() {
    challengeViewController.push(
      ChallengeDetailsViewController(challenge: challenge)
    )
  }
  
  private func presentCreateWorkout() {
    WorkoutFlow.logWorkout()
  }
  
  private func pushChat() {
    challengeViewController.push(
      ChatViewController(challenge: challenge)
    )
  }

  private func configureTabBar() {
    let pxWhiteThing = UIView(frame: CGRect(x: 0, y: -1, width: tabBar.frame.width, height: 1)).apply {
      $0.backgroundColor = .background
    }

    tabBar.isTranslucent = false
    tabBar.shadowImage = UIImage()
    tabBar.backgroundImage = UIImage()
    tabBar.layer.shadowOffset = .zero
    tabBar.layer.shadowRadius = 10
    tabBar.layer.shadowColor = UIColor.shadow.cgColor
    tabBar.layer.shadowOpacity = 0.5
    tabBar.barTintColor = .background
    tabBar.tintColor = .primaryText
    tabBar.unselectedItemTintColor = .primaryText
    tabBar.addSubview(pxWhiteThing)
    tabBar.sendSubviewToBack(pxWhiteThing)
  }
}

extension UITabBarController {
  func setTabBar(hidden: Bool, animated: Bool = true, alongside animator: UIViewPropertyAnimator? = nil) {
    guard tabBarIsHidden != hidden else { return }

    let offsetY = hidden ? (tabBar.frame.height + 30) : -(tabBar.frame.height + 30)
    let endFrame = tabBar.frame.offsetBy(dx: 0, dy: offsetY)
    var newInsets: UIEdgeInsets? = selectedViewController?.additionalSafeAreaInsets
    let originalInsets = newInsets
    newInsets?.bottom -= offsetY

    func set(childViewController: UIViewController?, additionalSafeArea: UIEdgeInsets) {
      childViewController?.additionalSafeAreaInsets = additionalSafeArea
      childViewController?.view.setNeedsLayout()
    }

    if let insets = newInsets, hidden {
      set(childViewController: selectedViewController, additionalSafeArea: insets)
    }

    guard animated else { tabBar.frame = endFrame; return }

    tabBar.isHidden = false
    
    if let animator = animator {
      animator.addAnimations {
        self.tabBar.frame = endFrame
      }
      
      animator.addCompletion { (position) in
        let insets = (position == .end) ? newInsets : originalInsets
        
        if let insets = insets, !hidden {
          set(childViewController: self.selectedViewController, additionalSafeArea: insets)
        }
        
        if (position == .end) {
          self.tabBar.isHidden = hidden
        }
      }
    } else {
      UIView.animate(withDuration: 0.35, animations: {
        self.tabBar.frame = endFrame
      }) { didFinish in
        if !hidden, didFinish, let insets = newInsets {
          set(childViewController: self.selectedViewController, additionalSafeArea: insets)
        }
        
        self.tabBar.isHidden = hidden
      }
    }
  }

  private var tabBarIsHidden: Bool {
    return !tabBar.frame.intersects(view.frame)
  }
}
